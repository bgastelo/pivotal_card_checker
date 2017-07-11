class CardViolation
  attr_accessor :id, :message

  def initialize(id = 0, message = nil)
    @id = id
    @message = message
  end
end
