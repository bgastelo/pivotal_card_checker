require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::EpicCardsChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'epic_cards_check' do
      api_key = 'using cassette'
      proj_id = 414_867
      data_retriever = PivotalCardChecker::DataRetriever.new(api_key, proj_id)
      @all_stories, @all_labels, @all_comments, @all_owners = data_retriever.retrieve_data
      @systems = PivotalCardChecker::CardChecker.new(api_key, proj_id).find_systems_to_deploy(true)
      @epic_labels = data_retriever.retrieve_epics
    end

    result = PivotalCardChecker::Checkers::EpicCardsChecker.new(@systems, @epic_labels, @all_labels).check

    expect(result['website redo spring 2017'].length).to eql(1)
    expect(result['website redo spring 2017'].first.name).to eql('Vlads Test Card')
  end
end