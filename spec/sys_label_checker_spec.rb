require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

module PivotalCardChecker
  module Checkers
    describe SysLabelChecker do
      attr_accessor :all_stories, :all_labels, :all_comments, :all_owners

      it 'should detect one story that is missing a prod info label' do
        VCR.use_cassette 'sys_label_check' do
          @all_stories, @all_labels, @all_comments, @all_owners =
            DataRetriever.new('using cassette', 414_867).retrieve_data
        end

        result = SysLabelChecker.new([@all_stories, @all_labels,
                                      @all_comments]).sys_label_check
        expect(result.length).to eql(1)
      end
    end
  end
end