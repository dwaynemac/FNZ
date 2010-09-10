class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.references :import
      t.integer   :cents
      t.string    :currency
      t.string    :description
      t.integer   :user_id
      t.integer   :account_id
      t.string    :type
      t.datetime  :made_on

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
