require 'pivotal_card_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::SystemsToDeployChecker do
=begin
  it 'should detect that we will be deploying only billing engine' do
    VCR.use_cassette 'no_systems_to_deploy' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new(@all_story_cards).check
    expect(result.length).to eql(0)
  end
=end

  it 'should detect that we are deploying: billing engine, cms, dct, marketing and reader' do
    VCR.use_cassette 'multiple_card_violations_response' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new(@all_story_cards).check
    expect(result.keys.sort).to eql(['billing engine', 'cms', 'dct', 'marketing', 'reader'])
  end
end
