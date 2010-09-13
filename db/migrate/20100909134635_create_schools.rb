class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.integer :padma_id
      t.string :name

      # configurations
      t.integer :default_account_id
      t.string  :default_currency, :default => "BRL"

      t.timestamps
    end
    add_column(:users, :school_id, :integer)
  end

  def self.down
    remove_column(:users, :school_id)
    drop_table :schools
  end
end
