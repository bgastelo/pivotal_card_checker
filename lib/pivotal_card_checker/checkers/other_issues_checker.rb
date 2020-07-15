module PivotalCardChecker
  module Checkers
    # Verifies the cards to see if any of them violate any smaller issues that we
    # classify as "other".
    class OtherIssuesChecker < Checker

      # Runs the validation method on all the cards, then returns the result.
      def check
        @all_story_cards.each do |story_card|
          violation_validation(story_card, story_card.has_commits?) if !story_card.has_label?('not_to_prod') && !story_card.has_label?('done when merged') 
        end
        @results
      end

      # Checks if the given story card violates any of the rules outlined below.
      def violation_validation(story_card, has_commits)
        state = story_card.current_state
        if state == 'finished' && !has_commits && !story_card.configuration_label?
          @results[story_card] = 'Card is marked \'finished\', but has no commits.'
        elsif state == 'delivered' &&
              !story_card.has_comment_that_contains?('staging acceptance')
          @results[story_card] = 'Card is marked \'delivered\', but doesn\'t have staging acceptance'
        elsif state == 'accepted' && has_commits &&
              story_card.has_label?('to_prod') &&
              !story_card.has_comment_that_contains?('prod acceptance') && !story_card.has_comment_that_contains?('production acceptance')
          @results[story_card] = 'Card is marked \'accepted\', but doesn\'t have prod acceptance'
        elsif (state == 'started' || state == 'unstarted') &&
              story_card.has_label?('to_prod')
          @results[story_card] = "Card is marked '#{state}', but has the 'to_prod' label."
        end
      end
    end
  end
end
