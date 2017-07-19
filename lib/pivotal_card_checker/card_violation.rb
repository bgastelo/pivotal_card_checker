module PivotalCardChecker
  # Holds the story id and error message for card violations.
  class CardViolation
    attr_reader :id, :message

    def initialize(id, message)
      @id = id
      @message = message
    end
  end
end