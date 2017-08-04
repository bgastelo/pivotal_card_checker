require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::AllCardsAssignedChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'unassigned_cards_check_two_violations' do
      @all_story_cards = PivotalCardChecker::DataRetriever.new('using cassette',
                                                      414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::AllCardsAssignedChecker.new(@all_story_cards).check

    expect(result.length).to eql(2)
    expect(result[0].id).to eql(149_315_387)
    expect(result[1].id).to eql(149_973_643)
  end
end