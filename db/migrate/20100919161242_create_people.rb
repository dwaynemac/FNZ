class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :padma_id
      t.references :institution
      t.string :name
      t.string :surname
      t.string :email
      t.datetime   :synced_at

      t.timestamps
    end

    add_column(:transactions,:person_id,:integer)
  end

  def self.down
    drop_table :people
    remove_column(:transactions,:person_id)
  end
end
