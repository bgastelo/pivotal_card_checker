require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::SysLabelChecker do
  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'sys_label_check' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        PivotalCardChecker::DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = PivotalCardChecker::Checkers::SysLabelChecker.new([@all_stories, @all_labels,
                                  @all_comments]).check
    expect(result.length).to eql(1)
  end
end