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
            u = User.find_by_drc_user(row[VH[:user]])
            if u.nil?
              u = self.user
              warnings << I18n.t('import.warnings.row_user_not_found')
            end

            cents = (row[VH[:income]]||"").to_money.cents - (row[VH[:expense]]||"").to_money.cents + (row[VH[:amount]]||"").to_money.cents

            data = {:made_on => row[VH[:date]], :description => row[VH[:description]],
                    :user_id => u.id, :category => row[VH[:category]]}

            account_field = row[VH[:account]]
            if account_field
              account = self.institution.accounts.find_by_name(account) || self.institution.accounts.find(account)
            end
            account = account.nil?? self.institution.default_account : account

            if cents < 0
              t = account.expenses.build(data.merge!({:cents => cents.abs}))
            else
              t = account.incomes.build(data.merge!({:cents => cents.abs}))
            end
            account.institution.tag(t,:on => :concepts, :with => row[VH[:concept_list]])
            if t.save
              (warnings << I18n.t('import.check_transaction_date')) if t.made_on.year != this_year
              self.imported_rows.create(:row => i, :transaction => t, :success => true, :message => warnings.join(" #{I18n.t('and', :default => ' and ')} "))
            else
              self.imported_rows.create(:row => i, :success => false, :message => t.errors.full_messages.join(" #{I18n.t('and', :default => ' and ')} "))
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
