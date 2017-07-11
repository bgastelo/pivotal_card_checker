require 'pivotal_card_checker/data_retriever'
require 'pivotal_card_checker/checkers/checker'
require 'pivotal_card_checker/checkers/acceptance_criteria_checker'
require 'tracker_api'
require 'spec_helper'

describe AcceptanceCritChecker do
  attr_accessor :all_stories, :all_labels, :all_comments, :all_owners

  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'acceptance_crit_check_one_violation' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = AcceptanceCritChecker.new([@all_stories, @all_labels,
                                        @all_comments]).acceptance_crit_check
    expect(result.length).to eql(1)
  end
end
