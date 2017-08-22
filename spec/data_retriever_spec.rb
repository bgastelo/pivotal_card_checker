require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::DataRetriever do
  it 'should retrieve all of the current and backlog cards.' do
    VCR.use_cassette 'data_retriever_test' do
      result = PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_data

      first_story = result.first

      expect(first_story.labels.first.name).to eql('subscriber request')
      expect(first_story.comments.first.nil?).to eql(false)
      expect(first_story.in_current_iteration).to eql(true)
    end
  end

  it 'should retrieve all of the epic labels.' do
    VCR.use_cassette 'data_retriever_epics_test' do
      result = PivotalCardChecker::DataRetriever.new(API_KEY, PROJECT_ID).retrieve_epics

      expect(result.first).to eql("pivotal card health tools")
    end
  end
end
