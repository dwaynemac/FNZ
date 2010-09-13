class Transfers < ActiveRecord::Migration
  def self.up
    create_table :transfers, :id => false do |t|
      t.integer :credit_id
      t.integer :debit_id
    end
  end

  def self.down
    drop_table :transfers
  end
end
