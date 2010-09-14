class CreateImportedRows < ActiveRecord::Migration
  def self.up
    create_table :imported_rows do |t|
      t.integer :import_id
      t.integer :transaction_id
      t.boolean :success
      t.integer :row
      t.string  :message

      t.timestamps
    end
  end

  def self.down
    drop_table :imported_rows
  end
end
