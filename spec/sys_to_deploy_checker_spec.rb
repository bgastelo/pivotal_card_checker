require 'pivotal_card_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::SystemsToDeployChecker do
  it 'should detect that we there are no systems to deploy' do
    VCR.use_cassette 'no_systems_to_deploy' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new(@all_story_cards).check
    expect(result.first.length).to eql(0)
  end

  it 'should detect that we are deploying: billing engine, cms, dct, marketing and reader' do
    VCR.use_cassette 'multiple_card_violations_response' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new(@all_story_cards).check
    expect(result.first.keys.sort).to eql(['billing engine', 'cms', 'dct', 'marketing', 'reader'])
  end
end
