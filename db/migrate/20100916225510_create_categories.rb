class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.integer :parent_id
      t.string :name
      t.integer :institution_id
      t.integer :cents
      t.string :currency
      t.datetime :saved_balance_on

      t.timestamps
    end

    add_column(:transactions, :category_id, :integer)
  end

  def self.down
    drop_table :categories
    remove_column(:transactions, :category_id)
  end
end
