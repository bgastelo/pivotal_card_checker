require 'pivotal_card_checker'
require 'pivotal_card_checker/checkers/sys_to_deploy_checker'
require 'tracker_api'
require 'spec_helper'

describe SystemsToDeployChecker do
  attr_reader :all_stories, :all_labels, :all_comments, :all_owners

  it 'should detect one story that is missing a prod info label' do
    VCR.use_cassette 'sys_to_deploy_test' do
      @all_stories, @all_labels, @all_comments, @all_owners =
        DataRetriever.new('using cassette', 414_867).retrieve_data
    end

    result = SystemsToDeployChecker.new([@all_stories, @all_labels,
                                         @all_comments]).find_systems_to_deploy
    expect(result.length).to eql(1)
    expect(result.first).to eql('billing engine')
  end
end
