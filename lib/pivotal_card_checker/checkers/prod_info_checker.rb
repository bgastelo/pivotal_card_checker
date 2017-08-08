module PivotalCardChecker
  module Checkers
    # Verifies that all of the candidate cards have one of the three prod
    # information labels (to_prod, delayed_prod, or not_to_prod).
    class ProdInfoChecker < Checker
      def check
        missing_prod_info = []

        @all_story_cards.each do |story_card|
          labels = story_card.labels
          next unless prod_info_candidate?(story_card) &&
                      !has_label?(labels, 'to_prod') &&
                      !has_label?(labels, 'delayed_prod') &&
                      !has_label?(labels, 'not_to_prod')
          missing_prod_info << story_card
        end
        missing_prod_info
      end

      def prod_info_candidate?(story_card)
        state = story_card.current_state
        state == 'finished' || state == 'delivered' || ((state == 'accepted' ||
        state == 'started') && has_commits?(story_card.comments))
      end
    end
  end
end
