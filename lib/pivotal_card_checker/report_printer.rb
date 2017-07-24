module PivotalCardChecker
  # Prints out the report when given the card violation info (bad_card_info).
  class ReportPrinter
    def initialize(bad_card_info, all_stories)
      @bad_card_info = bad_card_info
      @all_stories = all_stories
    end

    def print_report
      puts "\n========= Pivotal Card Checker ==========="
      if @bad_card_info.empty?
        puts 'CONGRATS! No card violations.'
      else
        print_card_violations
      end
    end

    def print_card_violations
      @bad_card_info.each do |owner_name, card_manager|
        puts "OWNER(s): #{owner_name}"
        print_section('        Missing prod description label (\'to_prod\', \'delayed_prod\', or \'not_to_prod\'):', card_manager.prod_info_issues, false)
        print_section('        Missing system label:', card_manager.sys_label_issues, true)
        print_section('        Missing acceptance criteria:', card_manager.acceptance_crit_issues, true)
        print_section('        Other issues:', card_manager.other_issues, true)
        puts "\n"
      end
    end

    def print_section(header_text, list, print_message)
      unless list.empty?
        puts header_text
        list.each do |violation|
          story_card = violation.story_card
          link = "https://www.pivotaltracker.com/story/show/#{story_card.id}"
          if print_message
            puts "                #{story_card.name} - #{link} - #{violation.message}"
          else
            puts "                #{story_card.name} - #{link}"
          end
        end
      end
    end
  end
end