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
  # The following are used by the CardViolationsManagers, to differentiate the
  # various violation lists.
  PROD_INFO_ISSUE = 1
  SYS_LABEL_ISSUE = 2
  ACCEPTANCE_CRIT_ISSUE = 3
  OTHER_ISSUE = 4
  UNASSIGNED_CARDS_ISSUE = 5

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    # TODO: add data validation?
  end

  # Checks all of our current and backlog cards for any of our specified
  # violations, returns a report containing all violations along with an
  # error message and the card owner(s) name.
  class CardChecker
    def initialize
      @api_key = PivotalCardChecker.configuration.api_key
      @proj_id = PivotalCardChecker.configuration.project_id
    end

    # Retrieves the necessary data, then passes it to 5 different checker objects,
    # then processes their output with a ViolationsOrganizer, before passing the
    # data to a ReportGenerator, which generates the report that is then returned.
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

    # This is the public check_cards method, it creates a new PivotalCardChecker
    # object, and runs the private check_cards method.
    def self.check_cards(generate_sys_to_deploy = true)
      card_checker = new
      # This (below) appends the 'Systems to deploy: ' info to the card report,
      # if generate_sys_to_deploy is true, else append ''.
      card_checker.check_cards << (generate_sys_to_deploy ? card_checker.generate_systems_to_deploy : '')
    end

    # Calls the find_systems_to_deploy method, then returns a string with the
    # output.
    def generate_systems_to_deploy
      systems = Checkers::SystemsToDeployChecker.new(@all_story_cards).check.first
      if systems.keys.empty?
        "No systems to deploy.\n"
      else
        "Systems to deploy: #{systems.keys.join(', ')}\n"
      end
    end

    # The public method that creates a new PivotalCardChecker and then calls
    # the private create_deploy_card method.
    def self.create_deploy_card(default_labels)
      card_checker = new
      card_checker.create_deploy_card(default_labels)
    end

    # Gathers and process all of the necessary information, then sends it to a
    # DeployCardCreator object to create the deploy card.
    def create_deploy_card(default_labels)
      deploy_card_creator = DeployCardCreator.new(@api_key, @proj_id,
                                                  default_labels)
      @all_story_cards = DataRetriever.new(@api_key, @proj_id).retrieve_data
      result = deploy_card_creator.deploy_card_already_exists(@all_story_cards)
      return "Deploy card already exists: https://www.pivotaltracker.com/story/show/#{result}" if result
      cards_to_deploy, deployed_cards = Checkers::SystemsToDeployChecker.new(@all_story_cards).check
      systems = merge_card_hashes(cards_to_deploy, deployed_cards)
      epic_labels = DataRetriever.new(@api_key, @proj_id).retrieve_epics
      reg_stories, epic_stories = Checkers::EpicCardsChecker.new(systems, epic_labels).check
      deploy_card_creator.create_deploy_card(cards_to_deploy, reg_stories, epic_stories)
    end

    # Merges the two hashes that map<String, Array>. This method is necessary
    # because deployed_cards.merge(cards_to_deploy) didn't work properly.
    def merge_card_hashes(cards_to_deploy, deployed_cards)
      cards_to_deploy.each do |labels, cards|
        cards.each do |story_card|
          deployed_cards[labels] << story_card
        end
      end
      deployed_cards
    end
  end
end
