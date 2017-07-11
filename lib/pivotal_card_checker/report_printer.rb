class ReportPrinter
  attr_accessor :bad_card_info
  
  def initialize(bad_card_info)
    @bad_card_info = bad_card_info
  end
  
  def print_report
    puts "\n========= Results ==========="
    if @bad_card_info.empty?
      puts 'CONGRATS! No card violations.'
    else
      print_card_violations
    end
  end
  
  def print_card_violations
    @bad_card_info.each do |owner_name, card_manager|
      puts "OWNER(s): #{owner_name}"
      print_section('        Missing prod description label (\'to_prod\', \'delayed_prod\', or \'not_to_prod\'):', card_manager.missing_prod_label, false)
      print_section('        Missing system label:', card_manager.missing_sys_label, true)
      print_section('        Missing acceptance criteria:', card_manager.missing_criteria, true)
      print_section('        Other issues:', card_manager.other_issues, true)
      puts "\n"
    end
  end
  
  def print_section(header_text, list, print_message)
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
