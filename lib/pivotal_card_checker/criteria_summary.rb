# frozen_string_literal: true

module PivotalCardChecker
  class CriteriaSummary
    def initialize
      @api_key = PivotalCardChecker.configuration.api_key
      @proj_id = PivotalCardChecker.configuration.project_id
    end

    def criteria_summary
      retriever = DataRetriever.new(@api_key, @proj_id)
      cards = retriever.search_stories('"acceptance criteria" state:finished,delivered')
      cards.map! do |card|
        OpenStruct.new(
          id: card.id,
          name: card.name,
          description: find_acceptance_criteria(card)
        )
      end
      cards_summary cards
    end

    # @param [TrackerApi::Resources::Story] card
    # @return [String,nil] Acceptance criteria if found
    def find_acceptance_criteria(card)
      comments = card.comments.map(&:text)
      (comments << card.description).each do |text|
        return text if text.include? '[acceptance criteria]'
      end
      nil
    end

    def cards_summary(cards)
      cards.map do |card|
        <<~TEXT
          **#{card.name}** - https://www.pivotaltracker.com/story/show/#{card.id}
          > #{card.description.gsub("\n", "\n> ")}

        TEXT
      end
    end
  end
end
