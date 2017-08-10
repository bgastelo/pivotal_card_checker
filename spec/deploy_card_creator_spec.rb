require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::DeployCardCreator do
  DEPLOY_LABEL_ID = 2_506_935

  it 'should create a deploy card with just one cms story' do
    VCR.use_cassette 'deploy_card_creation_8_9_2017' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_8_9_2017.txt'))

    correct_system_labels = ['cms', 'deploy']
    expect(@card_labels.sort).to eql(correct_system_labels.sort)
  end

  it 'should create a deploy card with consolidated labels under the website redo epic' do
    VCR.use_cassette 'deploy_card_creation_8_9_2017_consolidation_test_epic' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, reader deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_creation_8_9_2017_consolidation_test_epic.txt'))

    correct_system_labels = ['cms', 'deploy', 'reader']
    expect(@card_labels.sort).to eql(correct_system_labels.sort)
  end

  it 'should create a deploy card with consolidated labels not under any epic' do
    VCR.use_cassette 'deploy_card_creation_8_9_2017_consolidation_test_reg' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, reader deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_creation_8_9_2017_consolidation_test_reg.txt'))

    correct_system_labels = ['cms', 'deploy', 'reader']
    expect(@card_labels.sort).to eql(correct_system_labels.sort)
  end

  it 'should create a deploy card with cms and reader urls, but regular dct and mailroom labels.' do
    VCR.use_cassette 'deploy_card_creation_8_10_2017_label_urls' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, dct, reader, mailroom deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_creation_8_10_2017_label_urls.txt'))

    correct_system_labels = ['cms', 'dct', 'deploy', 'reader', 'mailroom']
    expect(@card_labels.sort).to eql(correct_system_labels.sort)
  end
end
