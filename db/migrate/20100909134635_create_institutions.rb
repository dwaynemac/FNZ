class CreateInstitutions < ActiveRecord::Migration
  def self.up
    create_table :institutions do |t|
      t.integer :padma_id
      t.string :name

      # configurations
      t.integer :default_account_id
      t.string  :default_currency, :default => "BRL"

      t.timestamps
    end
    add_column(:users, :institution_id, :integer)
  end

  def self.down
    remove_column(:users, :institution_id)
    drop_table :institutions
  end
end
