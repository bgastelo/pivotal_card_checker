require 'pivotal_card_checker'
require 'tracker_api'
require 'spec_helper'

describe DeployCardCreator do
  attr_reader :all_stories, :all_labels, :all_comments, :all_owners, :story

  it 'should create one deploy card with the properties tested below' do
    VCR.use_cassette 'deploy_card_creation_7_17_2017' do
      @story = PivotalCardChecker::CardChecker.create_deploy_card('using cassette', 414_867)
    end

    expect(@story.name).to eql('7/17/17 dct, reader deploy')
    expect(@story.description).to eql(IO.read('spec/expected_output/deploy_card_7_17_2017.txt'))
    expect(@story.story_type).to eql('chore')
    expect(@story.current_state).to eql('unstarted')

    story_labels = @story.labels.map(&:name)

    correct_system_labels = ['dct', 'deploy', 'reader']
    incorrect_system_labels = ['cms', 'billing engine', 'marketing', 'ui',
                               'pivotal card health tools', 'mailroom',
                               'common']

    expect(story_labels - correct_system_labels).to eql([])
    expect((story_labels & incorrect_system_labels).present?).to eql(false)
  end
end