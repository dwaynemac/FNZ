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
  has_many :transactions

  has_attached_file :csv_file
  # TODO FIXME validates_attachment_content_type :csv_file, :content_type => %w(  text/csv  )
  validates_attachment_presence :csv_file

  def load_data!
    return if self.csv_file.nil?
    self.start_import
    # TODO background
    FasterCSV.foreach(self.csv_file.path) do |row|
      if row.length == 5
        if self.school.default_account.nil? # if file doesn't specify account then default account is required
          break
        end
        # no account row
        data = {:made_on => row[0], :description => row[2], :amount => row[3].to_money.cents.abs,
                :import_id => self.id, :user_id => self.user_id, :concept_list => row[4]}
        if row[3] =~ /-\d*/
          t = self.school.default_account.expenses.build(data)
        else
          t = self.school.default_account.incomes.build(data)
        end
        t.save
      end
    end
    self.end_import_successfully
  end

end
