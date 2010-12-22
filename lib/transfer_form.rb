class TransferForm
  include Validatable
  attr_accessor :from_account_id, :to_account_id, :amount, :description, :made_on

  #validates_presence_of :from_account_id
  #validates_presence_of :to_account_id
  #validates_presence_of :amount

  validates_true_for :different_accounts, :logic => lambda { self.from_account_id != self.to_account_id }

  def initialize(attributes = nil)
    self.attributes = attributes
    yield self if block_given?
  end

  def attributes=(attributes)
    attributes.each do |key,value|
      send(key.to_s + '=', value)
    end if attributes
  end

  def attributes
    attributes = instance_variables
    attributes.delete("@errors")
    Hash[*attributes.collect { |attribute| [attribute[1..-1], instance_variable_get(attribute)] }.flatten]
  end

  def [](key)
    instance_variable_get("@#{key}")
  end

  def []=(key, value)
    instance_variable_set("@#{key}", value)
  end

  def method_missing( method_id, *args )
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self[attr_name] if self.respond_to?(attr_name)
    end
    super
  end
  alias_method :respond_to_without_attributes?, :respond_to?

  # for fromtastic
  def self.human_name
    return "transfer"
  end

end

