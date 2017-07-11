class ReportPrinter
  def initialize
  end
  
  def self.print_report(bad_card_info)
    puts "\n========= Results ==========="
    if bad_card_info.empty?
      puts 'CONGRATS! No card violations.'
    else
      bad_card_info.each do |owner_name, card_manager|
        puts "OWNER(s): #{owner_name}"
        print_from_list('        Missing prod description label (\'to_prod\', \'delayed_prod\', or \'not_to_prod\'):', card_manager.missing_prod_label, false)
        print_from_list('        Missing system label:', card_manager.missing_sys_label, true)
        print_from_list('        Missing acceptance criteria:', card_manager.missing_criteria, true)
        print_from_list('        Other issues:', card_manager.other_issues, true)
        puts "\n"
      end
    end
  end
  
  def print_from_list(header_text, list, print_message)
    unless list.empty?
      puts header_text
      list.each do |card|
        output = "                #{card.title} - #{card.link} - #{card.message}"
        if !print_message
          output = "                #{card.title} - #{card.link}"
        end
        puts output
      end
    end
  end
end
