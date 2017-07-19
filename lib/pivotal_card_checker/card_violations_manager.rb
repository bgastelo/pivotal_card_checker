module PivotalCardChecker
  # Manages the card violations by seperating them into four different
  # lists/types (prod info issues, system label issues, acceptance criteria
  # issues, and other/miscellaneous issues)
  class CardViolationsManager
    attr_reader :prod_info_issues, :sys_label_issues, :acceptance_crit_issues,
                :other_issues

    def initialize
      @prod_info_issues = []
      @sys_label_issues = []
      @acceptance_crit_issues = []
      @other_issues = []
    end

    def add_violation(type, story_id, message)
      violation = CardViolation.new(story_id, message)
      case type
      when PROD_INFO_ISSUE
        @prod_info_issues.push(violation)
      when SYS_LABEL_ISSUE
        @sys_label_issues.push(violation)
      when ACCEPTANCE_CRIT_ISSUE
        @acceptance_crit_issues.push(violation)
      when OTHER_ISSUE
        @other_issues.push(violation)
      else
        puts 'Invalid type.'
      end
    end
  end
end
