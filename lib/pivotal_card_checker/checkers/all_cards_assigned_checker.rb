module PivotalCardChecker
  module Checkers
    # Verifies that all of the given cards that are supposed to have acceptance
    # criteria, actually have acceptance criteria.
    class AllCardsAssignedChecker < Checker
      def check
        get_current_stories
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