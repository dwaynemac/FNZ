class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :drc_user
  end

  belongs_to :institution
  has_one :padma, :class_name => "PadmaToken", :dependent => :destroy

  has_many :transactions
  has_many :incomes
  has_many :expenses

  has_many :imports

  # returns boolean indication if user has access to the application.
  # currently, the condition is for user to have a connection to PADMA.
  def allowed?
    return self.connected_to_padma?
  end

  # returns boolean indicating if user has a OAuth connection to PADMA.
  def connected_to_padma?
    return !self.padma.nil?
  end

end #end