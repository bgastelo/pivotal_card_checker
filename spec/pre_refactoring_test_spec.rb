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
    it 'should produce output that matches the text in multiple_card_violations_output.txt' do
      # Cassette recorded July 6, 2017
      VCR.use_cassette 'multiple_card_violations_response' do
        printed = capture_stdout do
          PivotalCardChecker::CardChecker.check_cards('using cassette, no need for api key', 414_867)
        end

        printed.should eq(IO.read('spec/expected_output/multiple_card_violations_output.txt'))
      end
    end

    it 'should produce output that matches the text in no_card_violations_output.txt' do
      # Cassette recorded July 7, 2017
      VCR.use_cassette 'one_card_violation' do
        printed = capture_stdout do
          PivotalCardChecker::CardChecker.check_cards('using cassette, no need for api key', 414_867)
        end

        printed.should eq(IO.read('spec/expected_output/one_card_violation_output.txt'))
      end
    end
  end
end
