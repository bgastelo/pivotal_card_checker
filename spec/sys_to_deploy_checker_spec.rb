require 'pivotal_card_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::SystemsToDeployChecker do
  attr_reader :all_stories, :all_labels, :all_comments, :all_owners

  it 'should detect that we will be deploying only billing engine' do
    VCR.use_cassette 'sys_to_deploy_test' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new([@all_stories, @all_labels,
                                         @all_comments]).check
    expect(result.keys.length).to eql(1)
    expect(result.keys.first).to eql('billing engine')
  end

  it 'should detect that we are deploying: billing engine, cms, and reader' do
    VCR.use_cassette 'multiple_card_violations_response' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SystemsToDeployChecker.new([@all_stories, @all_labels,
                                         @all_comments]).check
    expect(result.keys).to eql(['billing engine', 'cms', 'reader'])
  end
end
