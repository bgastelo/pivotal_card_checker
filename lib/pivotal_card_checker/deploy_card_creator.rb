module PivotalCardChecker
  class DeployCardCreator
    def initialize(api_key, proj_id, default_label_ids)
      @api_key = api_key
      @proj_id = proj_id
      @default_label_ids = default_label_ids
    end

    def create_deploy_card(systems)
      title = "#{Time.now.strftime('%-m/%-d/%y')} #{systems.keys.join(', ')} deploy"
      card_description = create_card_description(systems)
      hedgeye_project = TrackerApi::Client.new(token: @api_key).project(@proj_id)
      story = hedgeye_project.create_story(name: title,
                                           description: card_description,
                                           story_type: 'Chore',
                                           current_state: 'unstarted',
                                           label_ids: @default_label_ids)
      # works, but would rather do in label_ids...
      systems.keys.each do |label_name|
        story.add_label(label_name)
        story.save
      end
    end

    def create_card_description(systems)
      card_description = ''
      systems.keys.each do |systems_label|
        card_description << "#{systems_label}\n"
        systems[systems_label].each do |story|
          card_description << "[#{story.name}](https://www.pivotaltracker.com/story/show/#{story.id})\n"
        end
        card_description << "\n"
      end
      return card_description
    end
  end
end
