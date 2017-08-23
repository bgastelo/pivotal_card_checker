module PivotalCardChecker
  # Manages the card violations by seperating them into four different
  # lists/types (prod info issues, system label issues, acceptance criteria
  # issues, and other/miscellaneous issues)
  class CardViolationsManager
    attr_reader :prod_info_issues, :sys_label_issues, :acceptance_crit_issues,
                :other_issues, :unassigned_cards_issues

    def initialize
      @prod_info_issues = []
      @sys_label_issues = []
      @acceptance_crit_issues = []
      @other_issues = []
      @unassigned_cards_issues = []
    end

    # Puts story cards and their error message into a CardViolation object, then
    # adds them to the appropriate list, based on type.
    def add_violation(type, story_card, message)
      violation = CardViolation.new(story_card, message)
      case type
      when PROD_INFO_ISSUE
        @prod_info_issues << violation
      when SYS_LABEL_ISSUE
        @sys_label_issues << violation
      when ACCEPTANCE_CRIT_ISSUE
        @acceptance_crit_issues << violation
      when OTHER_ISSUE
        @other_issues << violation
      when UNASSIGNED_CARDS_ISSUE
        @unassigned_cards_issues << violation
      else
        puts 'Invalid type.'
      end
    end
  end
end
