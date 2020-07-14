# PivotalCardChecker

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pivotal_card_checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pivotal_card_checker

## Usage

### Configuration

Setup gem by using:

```ruby
PivotalCardChecker.configure do |config|
  config.api_key = 'pivotal_api_key'
  config.project_id = 'pivotal_project_id'
  config.project_prefix = 'business-'
  config.label_urls = {
    'main' => 'www.site.com',
    'api' => 'api.site.com',
    'status' => 'status.site.com',
  }
  config.all_system_labels = [
    'main', 'api', 'status', 'pivotal card checker', 'docker' 
  ]
end
```

Fill out these configuration values so that they match your company's setup.

The `project_prefix` is used to identify related GitHub projects for each label. For
example, if your repo is called "business-api" and your label in Pivotal is "api",
the gem would expect the project prefix to be "business-".

The `label_urls` are used when generating the description of the deploy card. This
feature will associate your labels/repos with specific domains on the web. Often
this can be helpful for stakeholders to better understand the changes.

The `all_system_labels` is the definitive list of labels to check. These will be
correlated with GitHub repos and commits. Again, if your repos do not match these
labels, be sure to define the project prefix. The gem will expect to see a repo
called `main` or `business-main` using the example above.

**Also**, the tool will convert underscores to spaces in repo names like so:
```
repo: "pivotal_card_checker" becomes label: "pivotal card checker"
``` 

## Example Project

Sinatra is a simple Ruby web server. This example shows how to create HTTP endpoints for the card checker's actions.

```ruby
require 'sinatra'
require 'pivotal_card_checker'

PivotalCardChecker.configure do |config|
  config.api_key = ENV['API_KEY']
  config.project_id = ENV['PROJECT_ID']
  config.project_prefix = 'company-'
  config.label_urls = {
    'app' => 'www.example.com',
    'images' => 'images.example.com'
  }
  config.all_system_labels = ['app', 'images', 'admin']
end

get '/report' do
  content_type 'text'
  PivotalCardChecker::CardChecker.check_cards
end

get '/deploy_card' do
  DEPLOY_LABEL = 'deploy'
  result = PivotalCardChecker::CardChecker.create_deploy_card([DEPLOY_LABEL])

  content_type 'text'
  if result.is_a?(Array)
    "Successfully created deploy card: https://www.pivotaltracker.com/story/show/#{result[3]}"
  else
    result
  end
end

get '/validate' do
  content_type 'text'
  PivotalCardChecker::CardChecker.validate_cards
end
```

## Changelog

#### 0.1.1
Add special label for configuration-only cards

#### 0.1.0
Add Configuration object

#### 0.0.2
Change from using label ids to use label names.
