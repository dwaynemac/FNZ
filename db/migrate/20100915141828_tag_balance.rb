class TagBalance < ActiveRecord::Migration
  def self.up
    add_column(:tags, :currency, :string)
    add_column(:tags, :cents, :integer)
    add_column(:tags, :saved_balance_on, :datetime)
  end

  def self.down
    remove_column(:tags, :currency)
    remove_column(:tags, :cents)
    remove_column(:tags, :saved_balance_on)
  end
end