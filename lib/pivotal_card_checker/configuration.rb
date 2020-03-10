# frozen_string_literal: true

class Configuration
  attr_accessor :api_key, :project_id, :label_urls, :all_system_labels, :project_prefix

  def initialize
    @api_key = nil
    @project_id = nil
    # Used by DeployCardCreator, to create the card description.
    @label_urls = {}
    # Used in DeployCardCreator and StoryCard.
    @all_system_labels = []
    @project_prefix = nil
  end
end
