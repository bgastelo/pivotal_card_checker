require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::ProdInfoChecker do
  it 'should detect one finished story that is missing a prod info label' do
    VCR.use_cassette 'one_finished_card_missing_prod_info' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::ProdInfoChecker.new(@all_story_cards).check
    expect(result.length).to eql(6)
    expect(result[5].name).to eql('vlad test card 3')
  end

  it 'should detect five stories that are started w/ commits that are missing the prod label' do
    VCR.use_cassette 'five_cards_started_with_commits' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data
    end

    result = PivotalCardChecker::Checkers::ProdInfoChecker.new(@all_story_cards).check
    expect(result.length).to eql(5)
    expect(result[4].name).to eql('vladtestcard')
  end
end
