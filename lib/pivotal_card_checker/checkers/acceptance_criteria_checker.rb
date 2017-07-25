module PivotalCardChecker
  module Checkers
    # Verifies that all of the given cards that are supposed to have acceptance
    # criteria, actually have acceptance criteria.
    class AcceptanceCritChecker < Checker
      def check
        @all_story_cards.each do |story_card|
          next unless has_label?(story_card.labels, 'to_prod') &&
                      (story_card.current_state == 'finished' ||
                      story_card.current_state == 'delivered')
          if !has_acceptance_criteria(story_card.labels,
                                      story_card.description,
                                      story_card.comments)
            @results[story_card] = 'No acceptance criteria in desciption or comments.'
          elsif has_label?(story_card.labels, 'criteria needed')
            @results[story_card] = '\'criteria needed\' label was detected.'
          end
        end
        @results
      end

      def has_acceptance_criteria(labels, description, comments)
        # Check for 'criteria approved' label
        has_label?(labels, 'criteria approved') ||
          # Check for acceptance criteria in card descrption.
          (!description.nil? &&
          (description.downcase.include? 'acceptance criteria')) ||
          # Criteria not found in description, check comments.
          has_comment_that_contains?('acceptance criteria', comments)
      end
    end
  end
end