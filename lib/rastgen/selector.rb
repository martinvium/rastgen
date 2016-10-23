class Selector
  Pattern = Struct.new(:type, :identifier) do
    def any_id?
      identifier.nil?
    end
  end

  attr_reader :patterns

  def self.find(*args)
   new.find(*args)
  end

  def initialize
    @patterns = []
  end

  def find(type, identifier = nil)
    @patterns << Pattern.new(type, identifier)
   self
  end
end
