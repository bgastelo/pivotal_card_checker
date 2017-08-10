require 'pivotal_card_checker/version'
require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/report_generator'
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
require 'pivotal_card_checker/checkers/all_cards_assigned_checker'
require 'tracker_api'

module PivotalCardChecker
  PROD_INFO_ISSUE = 1
  SYS_LABEL_ISSUE = 2
  ACCEPTANCE_CRIT_ISSUE = 3
  OTHER_ISSUE = 4
  UNASSIGNED_CARDS_ISSUE = 5
  LABEL_URLS = { 'cms' => 'cms.hedgeye.com',
           'reader' => 'app.hedgeye.com',
           'billing engine' => 'accounts.hedgeye.com',
           'marketing' => 'www.hedgeye.com',
           'macro monitor' => 'drivers.hedgeye.com',
           'retail-data' => 'retail-data.hedgeye.com'
         }.freeze

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
                  Checkers::OtherIssuesChecker.new(@all_story_cards),
                  Checkers::AllCardsAssignedChecker.new(@all_story_cards)]
      results = []
      checkers.each do |checker|
        results << checker.check
      end

      bad_card_info = ViolationsOrganizer.new.organize(results)

      ReportGenerator.new(bad_card_info, @all_stories).generate_report
    end

    def self.check_cards(api_key, proj_id, generate_sys_to_deploy = true)
      card_checker = new(api_key, proj_id)
      card_checker.check_cards << (generate_sys_to_deploy ? card_checker.generate_systems_to_deploy : '')
    end

    def generate_systems_to_deploy
      systems = find_systems_to_deploy(false)
      if systems.keys.empty?
        "No systems to deploy.\n"
      else
        "Systems to deploy: #{systems.keys.join(', ')}\n"
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
      reg_stories, epic_stories = Checkers::EpicCardsChecker.new(systems, epic_labels).check
      DeployCardCreator.new(@api_key, @proj_id,
                            default_label_ids).create_deploy_card(systems,
                                                                  reg_stories,
                                                                  epic_stories)
    end
  end
end
