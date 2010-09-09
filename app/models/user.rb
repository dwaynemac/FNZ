class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :drc_user
  end
  has_one :padma, :class_name => "PadmaToken", :dependent => :destroy

  def allowed?
    return !self.padma.nil?
  end
end #end
