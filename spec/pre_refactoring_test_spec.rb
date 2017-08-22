require 'pivotal_card_checker'
require 'stringio'
require 'spec_helper'

class PivotalCardChecker::CardChecker
  describe 'Check the cards for any errors' do
    it 'should produce output that matches the text in multiple_card_violations_output.txt' do
      # Cassette recorded July 6, 2017
      VCR.use_cassette 'multiple_card_violations_response' do
        printed = 
          PivotalCardChecker::CardChecker.check_cards(API_KEY, PROJECT_ID)

        printed.should eq(IO.read('spec/expected_output/multiple_card_violations_output.txt'))
      end
    end

    it 'should produce output that matches the text in no_card_violations_output.txt' do
      VCR.use_cassette 'no_card_violations' do
        printed =
          PivotalCardChecker::CardChecker.check_cards(API_KEY, PROJECT_ID)

        printed.should eq(IO.read('spec/expected_output/no_card_violations_output.txt'))
      end
    end

    it 'should produce output that matches the text in no_cards_expecting_common_label.txt' do
      VCR.use_cassette 'no_cards_expecting_common_label' do
        printed =
          PivotalCardChecker::CardChecker.check_cards(API_KEY, PROJECT_ID)

        printed.should eq(IO.read('spec/expected_output/no_cards_expecting_common_label.txt'))
      end
    end

    it 'should produce output that matches the text in not_printing_sys_to_deploy.txt' do
      VCR.use_cassette 'no_cards_expecting_common_label' do
        printed =
          PivotalCardChecker::CardChecker.check_cards(API_KEY, PROJECT_ID, false)

        printed.should eq(IO.read('spec/expected_output/not_printing_sys_to_deploy.txt'))
      end
    end

    it 'should produce output that matches the text in output_with_an_unassigned_card.txt' do
      VCR.use_cassette 'output_with_an_unassigned_card' do
        printed =
          PivotalCardChecker::CardChecker.check_cards(API_KEY, PROJECT_ID)

        printed.should eq(IO.read('spec/expected_output/output_with_an_unassigned_card.txt'))
      end
    end
  end
end
