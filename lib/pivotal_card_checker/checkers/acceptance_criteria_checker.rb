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
          next unless story_card.has_label?('to_prod') &&
                      (story_card.current_state == 'finished' ||
                      story_card.current_state == 'delivered')
          if !story_card.has_acceptance_criteria?
            @results[story_card] = 'No acceptance criteria in description or comments.'
          elsif story_card.has_label?('criteria needed')
            @results[story_card] = '\'criteria needed\' label was detected.'
          end
        end
        @results
      end
    end
  end
end
