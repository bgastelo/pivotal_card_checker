module PivotalCardChecker
  # Creates a card that details the deployment (the "deploy card").
  class DeployCardCreator
    def initialize(api_key, proj_id, default_label_ids)
      @api_key = api_key
      @proj_id = proj_id
      @default_label_ids = default_label_ids
    end

    def create_deploy_card(systems, ordering)
      title = "#{Time.now.strftime('%-m/%-d/%y')} #{systems.keys.join(', ')} deploy"
      hedgeye_project = TrackerApi::Client.new(token: @api_key).project(@proj_id)
      card_description = create_card_description(ordering)
      card_labels = gather_card_label_ids(systems.keys).concat @default_label_ids
      hedgeye_project.create_story(name: title,
                                   description: card_description,
                                   story_type: 'Chore',
                                   current_state: 'unstarted',
                                   label_ids: card_labels)
    end

    def create_card_description(ordering)
      card_description = ''
      ordering.each do |label, stories|
        card_description << "#{label}\n"
        stories.each do |story|
          card_description << "[#{story.name}](https://www.pivotaltracker.com/story/show/#{story.id})\n"
        end
        card_description << "\n"
      end
      card_description
    end

    def gather_card_label_ids(system_labels)
      label_ids_for_deploy_card = []
      PivotalCardChecker::Checkers::ALL_SYSTEM_LABELS.zip(PivotalCardChecker::Checkers::ALL_SYS_LABEL_IDS).each do |name, id|
        label_ids_for_deploy_card.push(id) if system_labels.include? name
      end
      label_ids_for_deploy_card
    end

    def process_epics(project)
      labels = []
      project.epics.each do |label|
        labels.push(label.name)
      end
      labels
    end
  end
end
