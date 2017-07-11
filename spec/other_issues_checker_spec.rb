require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/checkers/checker'
require 'pivotal_card_checker/checkers/other_issues_checker'
require 'tracker_api'
require 'spec_helper'

describe OtherIssuesChecker do
  attr_accessor :all_stories, :all_labels, :all_comments, :all_owners

  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'other_issue_card_without_staging_acceptance' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = OtherIssuesChecker.new(@all_stories, @all_labels,
                                    @all_comments).other_issues_check

    expect(result.length).to eql(3)
  end
end
