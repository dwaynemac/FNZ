class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :drc_user
  end

  belongs_to :school
  has_one :padma, :class_name => "PadmaToken", :dependent => :destroy

  has_many :transactions
  has_many :incomes
  has_many :expenses

  def allowed?
    return self.connected_to_padma?
  end

  def connected_to_padma?
    return !self.padma.nil?
  end
end #end
