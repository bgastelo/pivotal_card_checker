module PivotalCardChecker
  # Holds the story id and error message for card violations.
  class CardViolation
    attr_reader :story_card, :message

    def initialize(story_card, message)
      @story_card = story_card
      @message = message
    end
  end
end