require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe PivotalCardChecker::DeployCardCreator do
  it 'should create one deploy card with the properties tested below' do
    VCR.use_cassette 'deploy_card_creation_7_19_2017' do
      DEPLOY_LABEL_ID = 2_506_935
      @deploy_card = PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867, [DEPLOY_LABEL_ID])
    end

    expect(@deploy_card.name).to eql('7/19/17 reader, cms deploy')
    expect(@deploy_card.description).to eql(IO.read('spec/expected_output/deploy_card_7_19_2017.txt'))
    expect(@deploy_card.story_type).to eql('chore')
    expect(@deploy_card.current_state).to eql('unstarted')

    story_labels = @deploy_card.labels.map(&:name)
    correct_system_labels = ['cms', 'deploy', 'reader']

    expect(story_labels - correct_system_labels).to eql([])
  end
end