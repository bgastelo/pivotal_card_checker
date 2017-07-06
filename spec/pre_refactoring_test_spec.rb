require 'pivotal_card_checker'
require 'stringio'
require 'spec_helper'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

class CardChecker
  describe 'Check the cards for any errors' do
    it 'should say that there are two missing prod labels for Alex.' do
      VCR.use_cassette 'pre_refactoring_reponse' do
        printed = capture_stdout do
          PivotalCardChecker::CardChecker.checkCards('insert api key')
        end

       printed.should eq(IO.read('spec/pre_refactoring_test_output.txt'))
      end
    end
  end
end
