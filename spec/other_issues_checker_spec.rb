require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::OtherIssuesChecker do
  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'other_issue_card_without_staging_acceptance' do
      @all_story_cards = 
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check
    expect(result.length).to eql(3)
  end

  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'multiple_card_violations_response' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check

    expect(result.length).to eql(2)
  end

  it 'should detect one story that is marked \'accepted\', but doesn\'t have prod acceptance' do
    VCR.use_cassette 'prod_acceptance_missing' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('6399a1acd7b2ab0ac1b30c00fb23f7e8', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check

    expect(result.length).to eql(2)
    expect(result.values.first).to eql('Card is marked \'accepted\', but doesn\'t have prod acceptance')
  end
end
