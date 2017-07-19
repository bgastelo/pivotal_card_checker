module PivotalCardChecker
  # Organizes the violations into a map of owner names -> card violations.
  class ViolationsOrganizer
    def initialize(all_stories, all_owners)
      @all_stories = all_stories
      @all_owners = all_owners
      @bad_card_info = Hash.new {}
    end

    def organize(prod_info, sys_label, acceptance_crit, other_issues)
      all_violations = [prod_info, sys_label, acceptance_crit, other_issues]
      types = [PROD_INFO_ISSUE, SYS_LABEL_ISSUE, ACCEPTANCE_CRIT_ISSUE,
               OTHER_ISSUE]

      types.zip(all_violations).each do |type, violations|
        process_list(type, violations)
      end

      @bad_card_info
    end

    def process_list(type, list)
      unless list.nil?
        list.each do |story_id, message|
          card_owners = get_owners(story_id)
          @bad_card_info[card_owners] =
            CardViolationsManager.new if @bad_card_info[card_owners].nil?
          @bad_card_info[card_owners].add_violation(type, story_id, message)
        end
      end
    end

    # Returns a comma seperated list of all the story's owners.
    def get_owners(story_id)
      owner_names = []
      @all_owners[story_id].each do |person|
        owner_names.push(person.name)
      end

      owner_names.join(', ')
    end
  end
end
