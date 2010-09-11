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
  belongs_to :school
  has_many :imported_rows
  has_many :transactions, :through => :imported_rows

  has_attached_file :csv_file
  validates_attachment_content_type :csv_file, :content_type => ['text/csv','text/comma-separated-values','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain','text/x-txt']
  validates_attachment_presence :csv_file

  def load_data!
    @errors = false
    if !self.csv_file.nil?
      begin
        self.start_import
        # TODO background
        i = 0
        FasterCSV.foreach(self.csv_file.path) do |row|
          if row.length == 5
            # no account row
            if self.school.default_account.nil?
              # if file doesn't specify account then default account is required
              @errors = true
              break
            else
              data = {:made_on => row[0], :description => row[2], :amount => row[3].to_money.cents.abs,
                      :user_id => self.user_id, :concept_list => row[4]}
              if row[3] =~ /-\d*/
                t = self.school.default_account.expenses.build(data)
              else
                t = self.school.default_account.incomes.build(data)
              end
              if t.save
                self.imported_rows.create(:transaction => t, :success => true)
              else
                self.imported_rows.create(:row => i, :success => false)
              end
            end
          end
          i += 1
        end
      rescue AASM::InvalidTransition
        @errors = true
      rescue
        # rollback
        self.transactions.delete_all
        self.imported_rows.delete_all
        @errors = true
        if RAILS_ENV != 'production'
          raise
        end
      end
    else
      @errors = true
    end
    @errors? self.end_import_with_error : self.end_import_successfully
    return !@errors
  end

end
