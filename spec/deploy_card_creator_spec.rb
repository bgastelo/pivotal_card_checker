require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::DeployCardCreator do
  it 'should create a deploy card with just one cms story' do
    VCR.use_cassette 'deploy_card_creation_8_9_2017' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card(API_KEY, PROJECT_ID, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_8_9_2017.txt'))
    expect(@card_labels.sort).to eql(['cms', 'deploy'])
  end

  it 'should create a deploy card with consolidated regular and epic labels' do
    VCR.use_cassette 'deploy_card_creation_8_24_2017_consolidation_test' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card(API_KEY, PROJECT_ID, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} billing engine, reader, cms, marketing deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_creation_8_24_2017_consolidation_test.txt'))
    expect(@card_labels.sort).to eql(['billing engine', 'cms', 'deploy', 'marketing', 'reader'])
  end

  it 'should create a deploy card with cms and reader urls, but regular dct and mailroom labels.' do
    VCR.use_cassette 'deploy_card_creation_8_10_2017_label_urls' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card(API_KEY, PROJECT_ID, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, dct, reader, mailroom deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_creation_8_10_2017_label_urls.txt'))
    expect(@card_labels.sort).to eql(['cms', 'dct', 'deploy', 'mailroom', 'reader'])
  end

  it 'should not be able to create a deploy card, because one already exists.' do
    VCR.use_cassette 'deploy_card_already_exists' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card(API_KEY, PROJECT_ID, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql('Deploy card already exists: https://www.pivotaltracker.com/story/show/150346573')
  end
end
