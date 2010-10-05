class Person < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false, :allow_nil => true, :scope => :institution_id
  validates_uniqueness_of :padma_id

  named_scope :full_name_like, lambda{|string|
    unless string.blank?
      string = string.strip
      tokens = string.split(' ', 2)
      { :conditions => ["nombres like :full or
      apellidos like :full or
      (nombres like :first and apellidos like :sec) or
      (apellidos like :first and nombres like :sec)",
      {:full => "%#{string}%", :first => "%#{tokens[0]}%",:sec => "%#{tokens[1]}%"}] }
    end
  }

  # If data not synced in last 5 hours or force=true, gets data from PADMA and syncs it to local DB.
  # Parameters:
  # <tt>PADMA AccessToken</tt>
  # <tt>boolean indicating to force sync</tt>
  def sync_from_padma(padma,force=false)
    synced = false
    if force || self.synced_at.nil? || self.synced_at < 5.hours.ago
      begin
        padma_data = padma.person(self.padma_id)
        if self.update_attributes(:name => padma_data["name"], :surname => padma_data["surname"])
          self.synced_at = Time.now
          synced = true
        end
      rescue
        logger.warn("#{Time.now}: Person#sync_from_padma: error in connection with PADMA")
      end
    else
      synced = true
    end
    return synced
  end

  def full_name
    return "#{self.name} #{self.surname}"
  end

  def padma_url
    Person.padma_url(self.padma_id)
  end

  def self.padma_url(id)
    return PADMA_API_URI+"/personas/"+id.to_s
  end
end
