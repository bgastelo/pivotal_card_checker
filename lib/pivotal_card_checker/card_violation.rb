class CardViolation
  attr_accessor :type, :title, :link, :message

  def initialize(type = 0, title = 'Default title', link = 'Default link', message = nil)
    @title = title
    @message = message
  end
end
