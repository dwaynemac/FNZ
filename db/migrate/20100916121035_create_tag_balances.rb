class CreateTagBalances < ActiveRecord::Migration
  def self.up
    create_table :tag_balances do |t|
      t.references :institution
      t.references :tag

      t.string     :currency
      t.integer    :cents

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_balances
  end
end
