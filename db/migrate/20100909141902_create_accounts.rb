class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.references :school
      t.string :name
      t.integer :cents
      t.string :currency

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
