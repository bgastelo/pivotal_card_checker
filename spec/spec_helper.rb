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
