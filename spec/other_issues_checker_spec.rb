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

  it 'should not detect a story with the label: not_to_prod' do
    VCR.use_cassette 'one_card_is_not_to_prod' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new(@all_story_cards).check
    expect(result.length).to eql(0)
  end

  describe '#check' do

    it 'ignores non accepted not to prod card' do
      card = card_with_state_and_label('finished', 'not_to_prod' )
      checker = PivotalCardChecker::Checkers::OtherIssuesChecker.new([card])
      checker.should_not_receive(:violation_validation)
      result = checker.check
      expect(result.length).to eql(0)
    end

    it 'ignores non accepted done when merged card' do
      card = card_with_state_and_label('finished', 'done when merged' )
      checker = PivotalCardChecker::Checkers::OtherIssuesChecker.new([card])
      checker.should_not_receive(:violation_validation)
      result = checker.check
      expect(result.length).to eql(0)
    end


    it 'ignores prod acceptance card' do
      card = card_with_state_and_label('accepted', 'to_prod' )
      card.comments << double('Comment', text: 'prod acceptance')
      checker = PivotalCardChecker::Checkers::OtherIssuesChecker.new([card])
      result = checker.check
      expect(result.length).to eql(0)
    end

    it 'ignores production acceptance card' do
      card = card_with_state_and_label('accepted', 'to_prod' )
      card.comments << double('Comment', text: 'production acceptance')
      checker = PivotalCardChecker::Checkers::OtherIssuesChecker.new([card])
      result = checker.check
      p result
      expect(result.length).to eql(0)
    end

  end
end
