module PivotalCardChecker
  module Checkers
    # Generic Checker class that contains attributes and methods that are used
    # by multiple *_checker classes.
    class Checker
      def initialize(all_story_cards)
        @all_story_cards = all_story_cards
        @results = Hash.new {}
      end

      def check
        puts 'Generic check method.'
      end

      # Criteria for a card being checked.
      def is_candidate?(story_card)
        state = story_card.current_state
        (state == 'finished' || state == 'delivered' || (state == 'accepted' &&
                                                         story_card.has_commits?)) && !story_card.has_label?('not_to_prod')  && !story_card.has_label?('done when merged') 
      end
    end
  end
end
