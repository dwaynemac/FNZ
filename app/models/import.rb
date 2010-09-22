class Import < ActiveRecord::Base
  include AASM

  aasm_initial_state  :ready
  aasm_column :aasm_state

  aasm_state  :ready
  aasm_state  :importing
  aasm_state  :imported
  aasm_state  :failed

  aasm_event(:start_import) { transitions :to => :importing, :from => :ready }
  aasm_event(:end_import_successfully) { transitions :to => :imported, :from => :importing }
  aasm_event(:end_import_with_error) { transitions :to => :failed, :from => :importing }

  belongs_to :user
  belongs_to :institution
  has_many :imported_rows, :dependent => :destroy
  has_many :transactions, :through => :imported_rows

  has_attached_file :csv_file
  validates_attachment_content_type :csv_file, :content_type => ['text/csv','text/comma-separated-values','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain','text/x-txt']
  validates_attachment_presence :csv_file

  
  def load_data!
    # TODO performance: use pure SQL?
    # TODO set users locale if done in background
    import_errors = []
    if !self.csv_file.nil?
      begin
        self.start_import
        # TODO background
        this_year = Time.zone.now.year
        i = 2
        FasterCSV.foreach(self.csv_file.path, :encoding => 'u', :headers => :first_row, :skip_blanks => true) do |row|
          if !self.institution.default_account && !row[VH[:account]]
            # if file doesn't specify account then default account is required
            import_errors << "no account"
            # rollback
            self.transactions.delete_all
            self.imported_rows.delete_all
            break
          else
            warnings = []
            u = self.institution.users.find_by_drc_user(row[VH[:user]])
            if u.nil?
              u = self.user
              warnings << I18n.t('import.warnings.row_user_not_found')
            end

            unless row[VH[:person]].blank?
              person_id = self.institution.people.full_name_like(row[VH[:person]]).first.try(:id)
              if person_id.nil? && !row[VH[:person]].blank?
                warnings << I18n.t('import.warnings.person_not_found_locally')
              end
            end

            # don't import transaction if no income, expense or amount were given
            if row[VH[:income]].blank? && row[VH[:expense]].blank? && row[VH[:amount]].blank?
              self.imported_rows.create(:row => i, :success => false, :message => I18n.t('import.no_amount_in_row'))
            else
              cents = (row[VH[:income]]||"").to_money.cents - (row[VH[:expense]]||"").to_money.cents + (row[VH[:amount]]||"").to_money.cents

              category = self.institution.categories.find_or_create_by_name(row[VH[:category]].capitalize) unless row[VH[:category]].blank?

              data = {:made_on => row[VH[:date]], :description => row[VH[:description]],
                      :user_id => u.id, :category_id => category.try(:id), :person_id => person_id}

              account_field = row[VH[:account]]
              if account_field
                account = self.institution.accounts.find_by_name(account_field) || self.institution.accounts.find(account_field)
              end
              account = account.nil?? self.institution.default_account : account

              if cents < 0
                t = account.expenses.build(data.merge!({:cents => cents.abs}))
              else
                t = account.incomes.build(data.merge!({:cents => cents.abs}))
              end
              account.institution.tag(t,:on => :concepts, :with => row[VH[:concept_list]])
              # save without callbacks to avoid constant recalculation of accounts, categories, etc balances.
              if t.save(:create_without_callbacks)
                (warnings << I18n.t('import.check_transaction_date')) if t.made_on.year != this_year
                self.imported_rows.create(:row => i, :transaction => t, :success => true, :message => warnings.join(" #{I18n.t('and', :default => ' and ')} "))
              else
                self.imported_rows.create(:row => i, :success => false, :message => t.errors.full_messages.join(" #{I18n.t('and', :default => ' and ')} "))
              end
            end

          end
          i += 1
        end
      rescue AASM::InvalidTransition
        import_errors << "aasm error"
        if RAILS_ENV != 'production'
          raise
        end
      rescue
        # rollback
        self.transactions.delete_all
        self.imported_rows.delete_all
        import_errors << "exception raised"
        if RAILS_ENV != 'production'
          raise
        end
      end
    else
      import_errors << "file not found"
    end
    (!import_errors.empty?)? self.end_import_with_error : self.end_import_successfully
    return import_errors
  end

  VALID_HEADERS = {
            :date => I18n.t('import.headers.date', :default => 'date'),
            :user => I18n.t('import.headers.user', :default => 'user'),
            :person => I18n.t('import.headers.person', :default => 'person'),
            :description => I18n.t('import.headers.description', :default => 'description'),
            :income => I18n.t('import.headers.income', :default => 'income'),
            :expense => I18n.t('import.headers.expense', :default => 'expense'),
            :amount => I18n.t('import.headers.amount', :default => 'amount'),
            :concept_list => I18n.t('import.headers.concept_list', :default => 'concept list'),
            :category => I18n.t('import.headers.category', :default => 'category'),
            :account => I18n.t('import.headers.account', :default => 'account'),
            }
  VH = VALID_HEADERS
end
