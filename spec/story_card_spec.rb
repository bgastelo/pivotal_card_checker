require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::StoryCard do
  describe '#get_system_label_from_commit' do
    it 'handles non commit comments' do
      comments = [double('Comment', text: 'has the string github.com/')]
      sc = PivotalCardChecker::StoryCard.new(id=1, name='card w/non commit github comment',
                                             'description', labels=[], comments, owners=[],
                                             current_state='Started', in_current_iteration=true
                                            )
      
      expect(sc.get_system_label_from_commit).to eq []
    end
  end
end
