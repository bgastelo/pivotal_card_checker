module PivotalCardChecker
  module Checkers
    # Verifies that all of the candidate cards have one of the three prod
    # information labels (to_prod, delayed_prod, or not_to_prod).
    class ProdInfoChecker < Checker

      # Loops through all of the stories and flags any cards that are considered
      # a candidate (is_candidate) and missing a prod description label
      # ('to_prod', 'delayed_prod', or 'not_to_prod').
      def check
        missing_prod_info = []

        @all_story_cards.each do |story_card|
          labels = story_card.labels
          next unless is_candidate?(story_card) &&
                      !story_card.has_label?('to_prod') &&
                      !story_card.has_label?('delayed_prod') &&
                      !story_card.has_label?('not_to_prod')  &&
                      !story_card.has_label?('done when merged')
          missing_prod_info << story_card
        end
        missing_prod_info
      end

      # Checks if the given card is a candidate for the prod_info_checker.
      def is_candidate?(story_card)
        state = story_card.current_state
        state == 'finished' || state == 'delivered' || ((state == 'accepted' ||
        state == 'started') && story_card.has_commits?)
      end
    end
  end
end
