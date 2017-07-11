require 'pivotal_card_checker/version'
require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/report_printer'
require 'pivotal_card_checker/checkers/checker'
require 'pivotal_card_checker/checkers/prod_info_checker'
require 'pivotal_card_checker/checkers/sys_label_checker'
require 'pivotal_card_checker/checkers/acceptance_criteria_checker'
require 'pivotal_card_checker/checkers/other_issues_checker'
#Dir[File.dirname(__FILE__) + 'pivotal_card_checker/checkers/*.rb'].each do |file| 
#  require File.basename(file, File.extname(file))
#end
require 'pivotal_card_checker/bad_card_manager'
require 'pivotal_card_checker/card_violation'
require 'pivotal_card_checker/violations_organizer'
require 'tracker_api'

module PivotalCardChecker
  MISSING_PROD_TYPE = 1
  MISSING_SYS_LABEL_TYPE = 2
  MISSING_CRITERIA_TYPE = 3
  OTHER_ISSUE_TYPE = 4

  class CardChecker
    attr_accessor :api_key, :proj_id

    def initialize(api_key, proj_id)
      @api_key = api_key
      @proj_id = proj_id
      @all_stories = Hash.new {}
      @all_labels = Hash.new {}
      @all_comments = Hash.new {}
      @all_owners = Hash.new {}
    end

    def check_cards
      @all_stories, @all_labels, @all_comments, @all_owners = DataRetriever.new(@api_key, @proj_id).retrieve_data

      lists = [@all_stories, @all_labels, @all_comments]
      prod_info_violations = ProdInfoChecker.new(lists).prod_check
      sys_label_violations = SysLabelChecker.new(lists).sys_label_check
      acceptance_violations = AcceptanceCritChecker.new(lists).acceptance_crit_check
      other_violations = OtherIssuesChecker.new(lists).other_issues_check
      # Stores all bad card info. Maps owner string to BadCardManager.
      bad_card_info = ViolationsOrganizer.new(@all_stories, @all_owners).organize(prod_info_violations, sys_label_violations, acceptance_violations, other_violations)

      ReportPrinter.new(bad_card_info, @all_stories).print_report

=begin
      lists = [@all_stories, @all_labels, @all_comments]
      organizer = ViolationsOrganizer.new(@all_stories, @all_owners)
      bad_card_info = organizer.organize(ProdInfoChecker.new(lists).prod_check,
                                         SysLabelChecker.new(lists).sys_label_check,
                                         AcceptanceCritChecker.new(lists).acceptance_crit_check,
                                         OtherIssuesChecker.new(lists).other_issues_check)
=end
    end

    def self.check_cards(api_key, proj_id)
      card_checker = new(api_key, proj_id)
      card_checker.check_cards
    end
  end
end
