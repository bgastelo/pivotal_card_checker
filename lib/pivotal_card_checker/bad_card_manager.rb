class BadCardManager
  attr_accessor :missing_prod_label, :missing_sys_label, :missing_criteria, :other_issues
  
  MISSING_PROD_TYPE = 1
  MISSING_SYS_LABEL_TYPE = 2
  MISSING_CRITERIA_TYPE = 3
  OTHER_ISSUE_TYPE = 4

  def initialize
    @missing_prod_label = []
    @missing_sys_label = []
    @missing_criteria = []
    @other_issues = []
  end

  def add_card(card)
    case card.type
    when MISSING_PROD_TYPE
      @missing_prod_label.push(card)
    when MISSING_SYS_LABEL_TYPE
      @missing_sys_label.push(card)
    when MISSING_CRITERIA_TYPE
      @missing_criteria.push(card)
    when OTHER_ISSUE_TYPE
      @other_issues.push(card)
    else
      puts 'Card not valid type.'
    end
  end

  def add_violation(type, story_id, message)
    violation = CardViolation.new(story_id, message)
    case type
    when MISSING_PROD_TYPE
      @missing_prod_label.push(violation)
    when MISSING_SYS_LABEL_TYPE
      @missing_sys_label.push(violation)
    when MISSING_CRITERIA_TYPE
      @missing_criteria.push(violation)
    when OTHER_ISSUE_TYPE
      @other_issues.push(violation)
    else
      puts 'Invalid type.'
    end
  end
end
