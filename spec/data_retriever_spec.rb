require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

module PivotalCardChecker
  module Checkers
    describe DataRetriever do
      it 'should retrieve all of the current and backlog cards.' do
        VCR.use_cassette 'data_retriever_test' do
          result = DataRetriever.new('using cassette', 414_867).retrieve_data

          first_story = result[0].values[0]
          first_label = result[1].values[0][0]
          first_comment = result[2].values[1][0]
          first_owner = result[3].values[0][0]

          expect(first_story).to be_a TrackerApi::Resources::Story
          expect(first_label).to be_a TrackerApi::Resources::Label
          expect(first_comment).to be_a TrackerApi::Resources::Comment
          expect(first_owner).to be_a TrackerApi::Resources::Person
        end
      end
    end
  end
end
