require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::DeployCardCreator do
  DEPLOY_LABEL_ID = 2_506_935

  it 'should create one deploy card with the properties tested below' do
    VCR.use_cassette 'deploy_card_creation_7_19_2017' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} reader, cms deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_7_19_2017.txt'))

    correct_system_labels = ['cms', 'deploy', 'reader']
    expect(correct_system_labels - @card_labels).to eql([])
  end

  it 'should create a deploy card description with multiple cards under cms, which is under website redo.' do
    VCR.use_cassette 'deploy_card_creation_7_25_2017' do
      @card_title, @card_description, @card_labels = 
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, billing engine deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_7_25_2017.txt'))

    correct_system_labels = ['billing engine', 'cms', 'deploy']
    expect(correct_system_labels - @card_labels).to eql([])
  end

  it 'should create a deploy card description with cards under cms and ui, which are both under website redo.' do
    VCR.use_cassette 'deploy_card_creation_7_25_2017_multiple_under_website_redo' do
      @card_title, @card_description, @card_labels =
        PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@card_title).to eql("#{Time.now.strftime('%-m/%-d/%y')} cms, billing engine, ui deploy")
    expect(@card_description).to eql(IO.read('spec/expected_output/deploy_card_7_25_2017_multiple_under_website_redo.txt'))

    correct_system_labels = ['billing engine', 'cms', 'deploy', 'ui']
    expect(correct_system_labels - @card_labels).to eql([])
  end
end