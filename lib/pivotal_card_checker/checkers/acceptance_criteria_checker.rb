module PivotalCardChecker
  module Checkers
    # Verifies that all of the given cards that are supposed to have acceptance
    # criteria, actually have acceptance criteria.
    class AcceptanceCritChecker < Checker
      def check
        @all_stories.each do |story_id, story|
          next unless has_label?(story_id, 'to_prod') &&
                      (story.current_state == 'finished' ||
                      story.current_state == 'delivered')
          if !has_acceptance_criteria(story_id,
                                      @all_stories[story_id].description)
            @results[story_id] = 'No acceptance criteria in desciption or comments.'
          elsif has_label?(story_id, 'criteria needed')
            @results[story_id] = '\'criteria needed\' label was detected.'
          end
        end
        @results
      end

      def has_acceptance_criteria(story_id, description)
        # Check for 'criteria approved' label
        has_label?(story_id, 'criteria approved') ||
          # Check for acceptance criteria in card descrption.
          (!description.nil? &&
          (description.downcase.include? 'acceptance criteria')) ||
          # Criteria not found in description, check comments.
          has_comment_that_contains?('acceptance criteria', story_id)
      end
    end
  end
end