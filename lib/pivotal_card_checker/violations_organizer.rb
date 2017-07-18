module PivotalCardChecker
  class ViolationsOrganizer
    attr_reader :all_stories, :all_owners, :results

    def initialize(all_stories, all_owners)
      @all_stories = all_stories
      @all_owners = all_owners
      @bad_card_info = Hash.new {}
    end

    def organize(prod_info, sys_label, acceptance_crit, other_issues)
      process_list(prod_info, MISSING_PROD_TYPE)
      process_list(sys_label, MISSING_SYS_LABEL_TYPE)
      process_list(acceptance_crit, MISSING_CRITERIA_TYPE)
      process_list(other_issues, OTHER_ISSUE_TYPE)

      return @bad_card_info
    end

    def process_list(list, type)
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
