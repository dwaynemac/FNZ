class SchoolsDefaultAccount < ActiveRecord::Migration
  def self.up
    add_column(:schools, :default_account_id, :integer)
  end

  def self.down
    remove_column(:schools, :default_account_id)
  end
end
