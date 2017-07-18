require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::OtherIssuesChecker do
  attr_reader :all_stories, :all_labels, :all_comments, :all_owners

  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'other_issue_card_without_staging_acceptance' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new([@all_stories, @all_labels,
                                     @all_comments]).check
    expect(result.length).to eql(3)
  end

  it 'should detect one story that is marked \'delivered\', but doesn\'t have staging acceptance' do
    VCR.use_cassette 'multiple_card_violations_response' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::OtherIssuesChecker.new([@all_stories, @all_labels,
                                     @all_comments]).check

    expect(result.length).to eql(2)
  end
end
