require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::ProdInfoChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'data_retriever_test' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::ProdInfoChecker.new([@all_stories, @all_labels,
                                  @all_comments]).check
    expect(result.length).to eql(2)
    story_name = 'I quite often see article tagged as "0". This shouldn\'t happen'
    expect(@all_stories[result[1]].name).to eql(story_name)
  end
end
