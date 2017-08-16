module PivotalCardChecker
  module Checkers
    # Verifies the cards to see if any of them violate any smaller issues that we
    # classify as "other"
    class OtherIssuesChecker < Checker
      def check
        @all_story_cards.each do |story_card|
          violation_validation(story_card, has_commits?(story_card.comments)) if !has_label?(story_card.labels, 'not_to_prod')
        end
        @results
      end

      def violation_validation(story_card, has_commits)
        state = story_card.current_state
        comments = story_card.comments
        labels = story_card.labels
        if state == 'finished' && !has_commits
          @results[story_card] = 'Card is marked \'finished\', but has no commits.'
        elsif state == 'delivered' &&
              !has_comment_that_contains?('staging acceptance', comments)
          @results[story_card] = 'Card is marked \'delivered\', but doesn\'t have staging acceptance'
        elsif state == 'accepted' && has_commits &&
              has_label?(labels, 'to_prod') &&
              !has_comment_that_contains?('prod acceptance', comments)
          @results[story_card] = 'Card is marked \'accepted\', but doesn\'t have prod acceptance'
        elsif (state == 'started' || state == 'unstarted') &&
              has_label?(labels, 'to_prod')
          @results[story_card] = "Card is marked '#{state}', but has the 'to_prod' label."
        end
      end
    end
  end
end
