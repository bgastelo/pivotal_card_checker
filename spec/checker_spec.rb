require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::Checkers::Checker do
  describe '#is_candidate?' do
    subject {  PivotalCardChecker::Checkers::Checker.new([]) }
    let(:commit_comment) {double('Comment', text: 'Commit by vlad')}

    it 'ignores accepted not_to_prod cards' do
      story_card = PivotalCardChecker::StoryCard.new(id = 12, 'card with not_to_prod', 'description', [label_stub('not_to_prod')], [commit_comment], [], 'accepted', true)
      expect(subject.is_candidate?(story_card)).to be_falsey
    end
    it 'ignores accepted done when merged cards' do
      story_card = PivotalCardChecker::StoryCard.new(id = 13, 'card with done when merged', 'description', [label_stub('done when merged')], [commit_comment], [], 'accepted', true)
      expect(subject.is_candidate?(story_card)).to be_falsey
    end

  end
end
