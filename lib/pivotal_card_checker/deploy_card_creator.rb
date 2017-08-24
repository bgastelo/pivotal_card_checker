module PivotalCardChecker
  # Creates a card that details the deployment (the "deploy card").
  class DeployCardCreator
    def initialize(api_key, proj_id, default_label_ids)
      @api_key = api_key
      @proj_id = proj_id
      @default_label_ids = default_label_ids
    end

    # Gathers all of the necessary card info (title, description, labels), then
    # calls the api to create the story. Returns the card info, which is used
    # in testing (deploy_card_creator_spec).
    def create_deploy_card(cards_to_deploy, reg_stories, epic_stories)
      hedgeye_project = TrackerApi::Client.new(token: @api_key).project(@proj_id)
      title = "#{Time.now.strftime('%-m/%-d/%y')} #{cards_to_deploy.keys.join(', ')} deploy"
      card_description = (epic_cards_description(epic_stories) <<
                          reg_cards_description(reg_stories)).rstrip
      card_labels = gather_card_label_ids(cards_to_deploy.keys).concat @default_label_ids
      hedgeye_project.create_story(name: title,
                                   description: card_description,
                                   story_type: 'Chore',
                                   current_state: 'unstarted',
                                   label_ids: card_labels)

      label_names = cards_to_deploy.keys << 'deploy'
      [title, card_description, label_names]
    end

    def deploy_card_already_exists(all_story_cards)
      checker = Checkers::Checker.new(nil)
      all_story_cards.each do |story|
        return story.id if checker.has_label?(story.labels, 'deploy')
      end
      false
    end

    # Combines stories with multiple system labels into one category. For example,
    # instead of having a story listed under both 'cms' and 'reader', they'll
    # be listed under 'cms, reader'.
    def consolidate_sys_labels(stories)
      inverted_stories = Hash.new { |hash, key| hash[key] = [] }
      stories.each do |label, story_cards|
        story_cards.each do |story_card|
          inverted_stories[story_card] << (LABEL_URLS[label].nil? ? label : LABEL_URLS[label])
        end
      end

      stories = Hash.new { |hash, key| hash[key] = [] }
      inverted_stories.each do |story_card, labels|
        stories[labels.join(', ')] << story_card
      end
      stories
    end

    # Adds the regular cards (stories not in an epic) to the desciption.
    def reg_cards_description(reg_stories)
      add_story_info_to_desc(consolidate_sys_labels(reg_stories), '')
    end

    # Adds the epic cards (cards that belong in an epic) to the description.
    def epic_cards_description(epic_stories)
      return '' if epic_stories.empty?
      card_description = ''
      epic_stories.each do |label, sys_map|
        card_description << "#{label}\n"
        stories = consolidate_sys_labels(sys_map)
        card_description = add_story_info_to_desc(stories, card_description,
                                                  false, '  ', '    ')
        card_description << "\n"
      end
      card_description
    end

    # Adds a list of stories to the deploy card description string.
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

    # Gathers all of the system label ids that the deploy card needs. The TrackerApi
    # only allows adding multiple labels if you use ids, as opposed to plaintext.
    def gather_card_label_ids(system_labels)
      label_ids_for_deploy_card = []
      PivotalCardChecker::Checkers::ALL_SYSTEM_LABELS.zip(PivotalCardChecker::Checkers::ALL_SYS_LABEL_IDS).each do |name, id|
        label_ids_for_deploy_card << id if system_labels.include? name
      end
      label_ids_for_deploy_card
    end
  end
end
