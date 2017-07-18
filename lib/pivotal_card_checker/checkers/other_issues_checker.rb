module PivotalCardChecker
  module Checkers
    # Verifies the cards to see if any of them violate any smaller issues that we
    # classify as "other"
    class OtherIssuesChecker < Checker
      def other_issues_check
        @all_stories.each do |story_id, story|
          violation_validation(story_id, story.current_state,
                               has_commits?(story_id))
        end
        @results
      end

      def violation_validation(story_id, state, has_commits)
        if state == 'finished' && !has_commits
          @results[story_id] = 'Card is marked \'finished\', but has no commits.'
        elsif state == 'delivered' &&
              !has_comment_that_contains?('staging acceptance', story_id)
          @results[story_id] = 'Card is marked \'delivered\', but doesn\'t have staging acceptance'
        elsif state == 'accepted' &&
              (has_comment_that_contains?('prod acceptance', story_id) &&
              !has_commits) && has_label?(story_id, 'to_prod')
          @results[story_id] = 'Card is marked \'accepted\', but doesn\'t have prod acceptance'
        elsif (state == 'started' || state == 'unstarted') &&
              has_label?(story_id, 'to_prod')
          @results[story_id] = "Card is marked '#{state}', but has the 'to_prod' label."
        end
      end
    end
  end
end
