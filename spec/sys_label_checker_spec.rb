require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::SysLabelChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'sys_label_check' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SysLabelChecker.new(@all_story_cards).check

    expect(result.length).to eql(1)
    expect(result.keys.first.name).to eql('vlad test card')
  end

  it 'should not consider ui to be a system label, hence zero results/violations' do
    VCR.use_cassette 'ui_sys_label_check' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SysLabelChecker.new(@all_story_cards).check
    expect(result.values.length).to eql(0)
  end

  it 'should not detect a story with the label: not_to_prod.' do
    VCR.use_cassette 'one_card_is_not_to_prod' do
      @all_story_cards =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SysLabelChecker.new(@all_story_cards).check
    expect(result.length).to eql(0)
  end
end
