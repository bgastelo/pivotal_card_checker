require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::EpicCardsChecker do
  it 'should detect one card that has the epic label: website redo spring 2017' do
    VCR.use_cassette 'epic_cards_check' do
      data_retriever = PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID)
      cards_to_deploy, deployed_cards = PivotalCardChecker::CardChecker.new(API_KEY, PROJECT_ID).find_systems_to_deploy(true)
      @systems = cards_to_deploy.merge(deployed_cards)
      @epic_labels = data_retriever.retrieve_epics
    end

    result = PivotalCardChecker::Checkers::EpicCardsChecker.new(@systems, @epic_labels).check

    expect(result[1]['website redo spring 2017'].length).to eql(1)
    expect(result[1]['website redo spring 2017']['reader'].first.name).to eql('Vlads Test Card')
  end
end