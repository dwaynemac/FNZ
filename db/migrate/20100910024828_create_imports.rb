class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.references  :user
      t.references  :school
      t.string      :csv_file_file_name
      t.string      :csv_file_content_type
      t.integer     :csv_file_file_size
      t.datetime    :csv_file_updated_at
      t.string      :aasm_state
      t.timestamps
    end
  end

  def self.down
    drop_table :imports
  end
end
