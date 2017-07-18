require 'pivotal_card_checker/version'
require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/report_printer'
require 'pivotal_card_checker/deploy_card_creator'
require 'pivotal_card_checker/card_violations_manager'
require 'pivotal_card_checker/card_violation'
require 'pivotal_card_checker/violations_organizer'
require 'pivotal_card_checker/checkers/checker'
require 'pivotal_card_checker/checkers/prod_info_checker'
require 'pivotal_card_checker/checkers/sys_label_checker'
require 'pivotal_card_checker/checkers/acceptance_criteria_checker'
require 'pivotal_card_checker/checkers/other_issues_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'tracker_api'

module PivotalCardChecker
  MISSING_PROD_TYPE = 1
  MISSING_SYS_LABEL_TYPE = 2
  MISSING_CRITERIA_TYPE = 3
  OTHER_ISSUE_TYPE = 4

  # Checks all of our current and backlog cards for any of our specified
  # violations, prints out a report containing all violations along with an
  # error message and the card owner(s) name.
  class CardChecker
    attr_reader :api_key, :proj_id

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
      prod_info_violations = Checkers::ProdInfoChecker.new(lists).prod_check
      sys_label_violations = Checkers::SysLabelChecker.new(lists).sys_label_check
      acceptance_violations =
        Checkers::AcceptanceCritChecker.new(lists).acceptance_crit_check
      other_violations = Checkers::OtherIssuesChecker.new(lists).other_issues_check
      bad_card_info =
        ViolationsOrganizer.new(@all_stories,
                                @all_owners).organize(prod_info_violations,
                                                      sys_label_violations,
                                                      acceptance_violations,
                                                      other_violations)

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

    def self.create_deploy_card(api_key, proj_id)
      card_checker = new(api_key, proj_id)
      card_checker.create_deploy_card
    end

    def find_systems_to_deploy(need_to_retrieve_data)
      @all_stories, @all_labels, @all_comments, @all_owners =
        DataRetriever.new(@api_key, @proj_id).retrieve_data if need_to_retrieve_data

      Checkers::SystemsToDeployChecker.new([@all_stories, @all_labels,
                                            @all_comments]).find_systems_to_deploy
    end

    def create_deploy_card
      DeployCardCreator.new(@api_key, @proj_id).create_deploy_card(find_systems_to_deploy(true))
    end
  end
end
