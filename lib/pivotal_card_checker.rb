require 'pivotal_card_checker/version'
require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/report_printer'
require 'pivotal_card_checker/deploy_card_creator'
require 'pivotal_card_checker/card_violations_manager'
require 'pivotal_card_checker/card_violation'
require 'pivotal_card_checker/violations_organizer'
require 'pivotal_card_checker/story_card'
require 'pivotal_card_checker/checkers/checker'
require 'pivotal_card_checker/checkers/prod_info_checker'
require 'pivotal_card_checker/checkers/sys_label_checker'
require 'pivotal_card_checker/checkers/acceptance_criteria_checker'
require 'pivotal_card_checker/checkers/other_issues_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'pivotal_card_checker/checkers/epic_cards_checker'
require 'tracker_api'

module PivotalCardChecker
  PROD_INFO_ISSUE = 1
  SYS_LABEL_ISSUE = 2
  ACCEPTANCE_CRIT_ISSUE = 3
  OTHER_ISSUE = 4

  # Checks all of our current and backlog cards for any of our specified
  # violations, prints out a report containing all violations along with an
  # error message and the card owner(s) name.
  class CardChecker
    def initialize(api_key, proj_id)
      @api_key = api_key
      @proj_id = proj_id
    end

    def check_cards
      @all_story_cards = DataRetriever.new(@api_key, @proj_id).retrieve_data

      checkers = [Checkers::ProdInfoChecker.new(@all_story_cards),
                  Checkers::SysLabelChecker.new(@all_story_cards),
                  Checkers::AcceptanceCritChecker.new(@all_story_cards),
                  Checkers::OtherIssuesChecker.new(@all_story_cards)]
      results = []
      checkers.each do |checker|
        results << checker.check
      end

      bad_card_info = ViolationsOrganizer.new.organize(results)

      ReportPrinter.new(bad_card_info, @all_stories).print_report
    end

    def self.check_cards(api_key, proj_id, print_sys_to_deploy = true)
      card_checker = new(api_key, proj_id)
      card_checker.check_cards
      card_checker.print_systems_to_deploy if print_sys_to_deploy
    end

    def print_systems_to_deploy
      systems = find_systems_to_deploy(false)
      if systems.keys.empty?
        puts 'No systems to deploy.'
      else
        puts "Systems to deploy: #{systems.keys.join(', ')}"
      end
    end

    def self.create_deploy_card(api_key, proj_id, default_label_ids)
      card_checker = new(api_key, proj_id)
      card_checker.create_deploy_card(default_label_ids)
    end

    def find_systems_to_deploy(need_to_retrieve_data)
      @all_story_cards = DataRetriever.new(@api_key, @proj_id).retrieve_data if need_to_retrieve_data

      Checkers::SystemsToDeployChecker.new(@all_story_cards).check
    end

    def create_deploy_card(default_label_ids)
      systems = find_systems_to_deploy(true)
      epic_labels = DataRetriever.new(@api_key, @proj_id).retrieve_epics
      ordering = Checkers::EpicCardsChecker.new(systems, epic_labels).check
      DeployCardCreator.new(@api_key, @proj_id,
                            default_label_ids).create_deploy_card(systems, ordering)
    end
  end
end
