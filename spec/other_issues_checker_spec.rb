require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::OtherIssuesChecker do
  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'other_issue_card_without_staging_acceptance' do
      @all_story_cards = 
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check
    expect(result.length).to eql(1)
    expect(result.first.first.name).to eql('Vlad test card')
  end

  it 'should detect one story that is marked \'accepted\', but doesn\'t have prod acceptance' do
    VCR.use_cassette 'prod_acceptance_missing' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check

    expect(result.length).to eql(1)
    expect(result.keys.first.name).to eql('Vlad test card')
  end

  it 'should not detect a story with the label: not_to_prod.' do
    VCR.use_cassette 'one_card_is_not_to_prod' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check
    expect(result.length).to eql(0)
  end
end
