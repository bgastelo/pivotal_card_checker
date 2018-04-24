require 'pivotal_card_checker'
require 'spec_helper'

describe PivotalCardChecker::ViolationsOrganizer do
  describe '#append_hipchat_mention' do
    # subject { PivotalCardChecker::ViolationsOrganizer.new }
    [
      ['Scott Smith', 'ssmith'],
      ['Diego Scataglini', 'dscataglini'],
      ['Andrew Berisha', 'aberisha'],
      ['Brett Novak', 'bnovak'],
      ['Forrest Chang', 'fchang'],
      ['Don Humphreys', 'dhumphreys'],
      ['Alex Handler', 'ahandler'],
      ['Alexis Santos', 'asantos']
    ].each { |full_name, hipchat_mention|
      it "extracts #{hipchat_mention} from #{full_name}" do
        expect(subject.append_hipchat_mention(full_name)).to eq "#{full_name} (@#{hipchat_mention})"
      end
    }
    
  end
  
end
