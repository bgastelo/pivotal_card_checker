require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::AcceptanceCritChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'acceptance_crit_check_one_violation' do
      @result = PivotalCardChecker::DataRetriever.new('using cassette',
                                                      414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::AcceptanceCritChecker.new(@result).check
    expect(result.length).to eql(1)
  end

  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'acceptance_crit_check_zero_violations' do
      @result = PivotalCardChecker::DataRetriever.new('using cassette',
                                                      414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::AcceptanceCritChecker.new(@result).check
    expect(result.length).to eql(0)
  end
end
