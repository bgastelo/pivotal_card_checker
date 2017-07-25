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

class PivotalCardChecker::CardChecker
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

    it 'should produce output that matches the text in no_cards_expecting_common_label.txt' do
      VCR.use_cassette 'no_cards_expecting_common_label' do
        printed = capture_stdout do
          PivotalCardChecker::CardChecker.check_cards('using cassette', 414_867)
        end

        printed.should eq(IO.read('spec/expected_output/no_cards_expecting_common_label.txt'))
      end
    end

    it 'should produce output that matches the text in output_with_an_unassigned_card.txt' do
      VCR.use_cassette 'output_with_an_unassigned_card' do
        printed = capture_stdout do
          PivotalCardChecker::CardChecker.check_cards('using cassette', 414_867)
        end

        printed.should eq(IO.read('spec/expected_output/output_with_an_unassigned_card.txt'))
      end
    end
  end
end
