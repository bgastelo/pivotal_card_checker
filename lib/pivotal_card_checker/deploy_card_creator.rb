module PivotalCardChecker
  # Creates a card that details the deployment (the "deploy card").
  class DeployCardCreator
    def initialize(api_key, proj_id, default_label_ids)
      @api_key = api_key
      @proj_id = proj_id
      @default_label_ids = default_label_ids
    end

    def create_deploy_card(systems, reg_stories, epic_stories)
      title = "#{Time.now.strftime('%-m/%-d/%y')} #{systems.keys.join(', ')} deploy"
      hedgeye_project = TrackerApi::Client.new(token: @api_key).project(@proj_id)
      card_description = (epic_cards_description(epic_stories) <<
                          reg_cards_description(reg_stories)).rstrip
      card_labels = gather_card_label_ids(systems.keys).concat @default_label_ids
      hedgeye_project.create_story(name: title,
                                   description: card_description,
                                   story_type: 'Chore',
                                   current_state: 'unstarted',
                                   label_ids: card_labels)

      label_names = systems.keys << 'deploy'
      [title, card_description, label_names]
    end

    def reg_cards_description(reg_stories)
      add_story_info_to_desc(reg_stories, '')
    end

    def epic_cards_description(epic_stories)
      return '' if epic_stories.empty?
      card_description = ''
      epic_stories.each do |label, sys_map|
        card_description << "#{label}\n"
        card_description = add_story_info_to_desc(sys_map, card_description,
                                                  false, '  ', '    ')
        card_description << "\n"
      end
      card_description
    end

    def add_story_info_to_desc(stories, card_description, is_reg_stories = true,
                               label_spacing = '', card_name_spacing = '')
      stories.each do |label, story_cards|
        card_description << "#{label_spacing}#{label}\n"
        story_cards.each do |story_card|
          card_description << "#{card_name_spacing}[#{story_card.name}](https://www.pivotaltracker.com/story/show/#{story_card.id})\n"
        end
        card_description << "\n" if is_reg_stories
      end
      card_description
    end

    def gather_card_label_ids(system_labels)
      label_ids_for_deploy_card = []
      PivotalCardChecker::Checkers::ALL_SYSTEM_LABELS.zip(PivotalCardChecker::Checkers::ALL_SYS_LABEL_IDS).each do |name, id|
        label_ids_for_deploy_card << id if system_labels.include? name
      end
      label_ids_for_deploy_card
    end

    def process_epics(project)
      labels = []
      project.epics.each do |label|
        labels << label.name
      end
      labels
    end
  end
end
