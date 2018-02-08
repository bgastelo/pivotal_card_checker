require 'vcr'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

API_KEY = 'using cassette'
PROJECT_ID = 414_867
DEPLOY_LABEL_ID = 2_506_935

VCR.config do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.stub_with :webmock
end

# test method to make a stub label
def label_stub(label)
  double('Label', name: label)
end

def card_with_state_and_label(state, label)
  PivotalCardChecker::StoryCard.new(id = 12, 'card with not_to_prod', 'description', [label_stub(label)], [double('Comment', text: 'Commit by vlad')], [], state, true)
end


