module PivotalCardChecker
  module Checkers
    # Verifies that all of the given cards that are supposed to have acceptance
    # criteria, actually have acceptance criteria.
    class AcceptanceCritChecker < Checker

      # Checks cards that have one of the following labels: 'to_prod',
      # 'finished', or 'delivered'. If a card doesn't have acceptance criteria,
      # or it has the 'criteria needed' label, it gets added to the @results
      # list, with its corresponding error message.
      def check
        @all_story_cards.each do |story_card|
          next unless has_label?(story_card.labels, 'to_prod') &&
                      (story_card.current_state == 'finished' ||
                      story_card.current_state == 'delivered')
          if !has_acceptance_criteria?(story_card.labels,
                                      story_card.description,
                                      story_card.comments)
            @results[story_card] = 'No acceptance criteria in description or comments.'
          elsif has_label?(story_card.labels, 'criteria needed')
            @results[story_card] = '\'criteria needed\' label was detected.'
          end
        end
        @results
      end

      # Checks if a story card has acceptance criteria. First it checks if the
      # card has the label 'criteria approved', then it checks if the 'description'
      # has the text 'acceptance criteria', and lastly, it checks if the card
      # has a comment that contains the text 'acceptance criteria'.
      def has_acceptance_criteria?(labels, description, comments)
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