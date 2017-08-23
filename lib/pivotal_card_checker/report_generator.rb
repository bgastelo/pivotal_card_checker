module PivotalCardChecker
  # Prints out the report when given the card violation info (bad_card_info).
  class ReportGenerator
    def initialize(bad_card_info, all_stories)
      @bad_card_info = bad_card_info
      @all_stories = all_stories
    end

    # Initializes the report, processes the card info data, and then returns the
    # report, as a string.
    def generate_report
      report = "========= Pivotal Card Checker ===========\n"
      if @bad_card_info.empty?
        report << "CONGRATS! No card violations.\n\n"
      else
        report << print_card_violations
      end
    end

    # Loops through the card violations, processes each one, then returns the
    # result.
    def print_card_violations
      card_violations = ''
      @bad_card_info.each do |owner_name, card_manager|
        card_violations << "OWNER(s): #{owner_name}\n"
        card_violations << print_section("        Missing prod description label (\'to_prod\', \'delayed_prod\', or \'not_to_prod\'):\n", card_manager.prod_info_issues, false)
        card_violations << print_section("        Missing system label(s):\n", card_manager.sys_label_issues, true)
        card_violations << print_section("        Missing acceptance criteria:\n", card_manager.acceptance_crit_issues, true)
        card_violations << print_section("        Other issues:\n", card_manager.other_issues, true)
        card_violations << print_section("        Nobody is assigned to the following card(s):\n", card_manager.unassigned_cards_issues, false)
        card_violations <<  "\n"
      end
      card_violations
    end

    # Appends a section to the report. This includes the section heading (missing system label(s),
    # missing acceptance criteria, etc.), and all of the violation information (story name,
    # link, message).
    def print_section(header_text, list, print_message)
      violation_section = ''
      unless list.empty?
        violation_section << header_text
        list.each do |violation|
          story_card = violation.story_card
          link = "https://www.pivotaltracker.com/story/show/#{story_card.id}"
          if print_message
            violation_section << "                #{story_card.name} - #{link} - #{violation.message}\n"
          else
            violation_section << "                #{story_card.name} - #{link}\n"
          end
        end
      end
      violation_section
    end
  end
end