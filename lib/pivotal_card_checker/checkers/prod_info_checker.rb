module PivotalCardChecker
  module Checkers
    # Verifies that all of the candidate cards have one of the three prod
    # information labels (to_prod, delayed_prod, or not_to_prod).
    class ProdInfoChecker < Checker
      def check
        missing_prod_info = []

        @all_stories.each do |story_id, story|
          next unless is_candidate?(story_id, story.current_state) &&
                      !has_label?(story_id, 'to_prod') &&
                      !has_label?(story_id, 'delayed_prod') &&
                      !has_label?(story_id, 'not_to_prod')
          missing_prod_info.push(story_id)
        end
        missing_prod_info
      end
    end
  end
end
