require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::EpicCardsChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'epic_cards_check' do
      api_key = 'using cassette'
      proj_id = 414_867
      data_retriever = PivotalCardChecker::DataRetriever.new(api_key, proj_id)
      @systems = PivotalCardChecker::CardChecker.new(api_key, proj_id).find_systems_to_deploy(true)
      @epic_labels = data_retriever.retrieve_epics
    end

    result = PivotalCardChecker::Checkers::EpicCardsChecker.new(@systems, @epic_labels).check

    expect(result[1]['website redo spring 2017'].length).to eql(1)
    expect(result[1]['website redo spring 2017']['cms'].first.name).to eql('Vlads Test Card')
  end
end