require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::ProdInfoChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'one_card_missing_prod_info' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::ProdInfoChecker.new(@all_story_cards).check
    expect(result.length).to eql(1)
    story_name = 'ETF Pro promo product detail pages pricing copy'
    expect(result.first.name).to eql(story_name)
  end
end
