module PivotalCardChecker
  module Checkers
    # Verifies that all of the given cards that are supposed to have acceptance
    # criteria, actually have acceptance criteria.
    class AllCardsAssignedChecker < Checker
      def check
        @results = []
        @all_story_cards.each do |story_card|
          @results << story_card if story_card.owners.empty? && story_card.in_current_iteration
        end
        @results
      end
    end
  end
end
