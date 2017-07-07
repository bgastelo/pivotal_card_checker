require 'pivotal_card_checker/version'
require 'tracker_api'

module PivotalCardChecker
  MISSING_PROD_TYPE = 1
  MISSING_SYS_LABEL_TYPE = 2
  MISSING_CRITERIA_TYPE = 3
  OTHER_ISSUE_TYPE = 4

  class CardChecker
    attr_accessor :api_key, :proj_id

    def initialize(api_key = 0, proj_id = 0)
      @api_key = api_key
      @proj_id = proj_id
      @all_stories = Hash.new {}
      @all_labels = Hash.new {}
      @all_comments = Hash.new {}
      @all_owners = Hash.new {}
    end

    def check_cards
      client = TrackerApi::Client.new(token: api_key)
      hedgeye_project = client.project(proj_id)

      # Stores all bad card info. Maps owner string to BadCardManager.
      bad_card_info = Hash.new {}

      # Gets the current iteration and all backlog iterations.
      iterations = hedgeye_project.iterations(scope: :current_backlog)

      should_have_to_prod = []

      iterations.each do |iteration|
        iteration.stories.each do |story|
          curr_id = story.id
          @all_stories[curr_id] = story
          @all_labels[curr_id] = story.labels
          @all_comments[curr_id] = story.comments
          @all_owners[curr_id] = story.owners
        end
      end

      find_candidate_stories(should_have_to_prod)
      analyze_candidates(should_have_to_prod, bad_card_info)
      print_report(bad_card_info)
    end

    def self.check_cards(api_key, proj_id)
      card_checker = new(api_key, proj_id)
      card_checker.check_cards
    end

    def find_candidate_stories(should_have_to_prod)
      @all_stories.each do |story_id, story|
        state = story.current_state
        if state == 'finished' || state == 'delivered' || state == 'accepted'
          should_have_to_prod.push(story)
        elsif search_comments(story_id, 'Commit by') != 'not found'
          should_have_to_prod.push(story)
        end
      end
    end

    def analyze_candidates(should_have_to_prod, bad_card_info)
      should_have_to_prod.each do |story|
        story_id = story.id
        card_owners = get_owners(story_id)
        if story.current_state == 'accepted'
          if (search_comments(story_id, 'prod acceptance') == 'not found' &&
            get_system_label_from_commit(story_id) != 'sysLabelUnknown') &&
            has_label?(story_id, 'to_prod')
            if bad_card_info[card_owners].nil?
              bad_card_info[card_owners] = BadCardManager.new
            end
            bad_card_info[card_owners].add_card(BadCard.new(OTHER_ISSUE_TYPE,
                                                            story.name,
                                                            "https://www.pivotaltracker.com/story/show/#{story_id}",
                                                            'Card is marked \'accepted\', but doesn\'t have prod acceptance'))
          end
          next
        end
        has_prod_label = false
        has_sys_label = false
        needs_criteria = true
        sys_label_detected = 'None'
        sys_label_from_commit = get_system_label_from_commit(story_id)
        temp = []

        @all_labels[story_id].each do |label|
          if label.name == 'to_prod'
            has_prod_label = true
          elsif label.name == 'not_to_prod' || label.name == 'delayed_prod'
            has_prod_label = true
            needs_criteria = false
          end
          if system_label?(label.name)
            sys_label_detected = label.name
            has_sys_label = true
          end
        end

        # If the card doesn't have a to_prod label.
        if !has_prod_label
          temp.push(BadCard.new(MISSING_PROD_TYPE, story.name,
                                "https://www.pivotaltracker.com/story/show/#{story_id}"))
        elsif needs_criteria && (story.current_state == 'finished' || story.current_state == 'delivered')
          message = 'None'
          if !has_acceptance_criteria(story_id)
            message = 'No acceptance criteria in desciption or comments.'
          elsif has_label?(story_id, 'criteria needed')
            message = '\'criteria needed\' label was detected.'
          end

          if message != 'None'
            temp.push(BadCard.new(MISSING_CRITERIA_TYPE, story.name,
                                  "https://www.pivotaltracker.com/story/show/#{story_id}", message))
          end
        end

        if !has_sys_label
          message = 'No system labels detected (reader, cms, dct, etc...)'
          if sys_label_from_commit != 'sysLabelUnknown'
            message = "Did not find expected label: '#{sys_label_from_commit}'"
          end

          temp.push(BadCard.new(MISSING_SYS_LABEL_TYPE, story.name,
                                "https://www.pivotaltracker.com/story/show/#{story_id}", message))
        elsif sys_label_from_commit != 'sysLabelUnknown' && !has_label?(story_id, sys_label_from_commit)
          temp.push(BadCard.new(MISSING_SYS_LABEL_TYPE, story.name,
                                "https://www.pivotaltracker.com/story/show/#{story_id}",
                                "Expected label: '#{sys_label_from_commit}', but found '#{sys_label_detected}' instead."))
        end

        if story.current_state == 'finished' && sys_label_from_commit == 'sysLabelUnknown'
          temp.push(BadCard.new(OTHER_ISSUE_TYPE, story.name,
                                "https://www.pivotaltracker.com/story/show/#{story_id}",
                                'Card is marked \'finished\', but has no commits.'))
        elsif story.current_state == 'delivered' && search_comments(story_id, 'staging acceptance') == 'not found'
          temp.push(BadCard.new(OTHER_ISSUE_TYPE, story.name,
                                "https://www.pivotaltracker.com/story/show/#{story_id}",
                                'Card is marked \'delivered\', but doesn\'t have staging acceptance'))
        end

        unless temp.empty?
          if bad_card_info[card_owners].nil?
            bad_card_info[card_owners] = BadCardManager.new
          end
          temp.each do |card|
            bad_card_info[card_owners].add_card(card)
          end
        end
      end
    end

    def print_report(bad_card_info)
      puts "\n========= Results ==========="
      if bad_card_info.empty?
        puts 'CONGRATS! No card violations.'
      else
        bad_card_info.each do |owner_name, card_manager|
          puts "OWNER(s): #{owner_name}"
          unless card_manager.missing_prod_label.empty?
            puts '        Missing prod description label (\'to_prod\', \'delayed_prod\', or \'not_to_prod\'):'
            card_manager.missing_prod_label.each do |card|
              puts "                #{card.title} - #{card.link}"
            end
          end

          unless card_manager.missing_sys_label.empty?
            puts '        Missing system label:'
            card_manager.missing_sys_label.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end

          unless card_manager.missing_criteria.empty?
            puts '        Missing acceptance criteria:'
            card_manager.missing_criteria.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end

          unless card_manager.other_issues.empty?
            puts '        Other issues:'
            card_manager.other_issues.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end
          puts "\n"
        end
      end
    end

    # Returns a comma seperated list of all the story's owners.
    def get_owners(story_id)
      owner_names = []
      @all_owners[story_id].each do |person|
        owner_names.push(person.name)
      end

      owner_names.join(', ')
    end

    # Returns true if the given label name is a system label.
    def system_label?(label_name)
      label_name == 'cms' || label_name == 'billing engine' || label_name == 'dct' ||
      label_name == 'reader' || label_name == 'marketing' || label_name == 'ui' ||
      label_name == 'pivotal card health tools' || label_name == 'mailroom'
    end

    def get_system_label_from_commit(story_id)
      temp = 'sysLabelUnknown'
      search_result = search_comments(story_id, 'github.com/')

      if search_result != 'not found'
        temp = search_result.split(/github.com\/(.*?)\/(.*?)\/commit/)[2]
        if temp.include? 'hedgeye-'
          temp = temp[8...temp.length]
        end
        temp.tr!('_', ' ')
      end
      result = temp
    end

    def has_acceptance_criteria(story_id)
      story = @all_stories[story_id]
      has_criteria = false

      # Check in labels for 'criteria approved'
      if has_label?(story_id, 'criteria approved')
        has_criteria = true
      # Check for acceptance criteria in card descrption.
      elsif !story.description.nil? && (story.description.downcase.include? 'acceptance criteria')
        has_criteria = true
      # Criteria not found in description, check comments.
      elsif search_comments(story_id, 'acceptance criteria') != 'not found'
        has_criteria = true
      end
      temp = has_criteria
    end

    def has_label?(story_id, label_looking_for)
      found = false
      @all_labels[story_id].each do |label|
        if label.name == label_looking_for
          found = true
          break
        end
      end
      result = found
    end

    def search_comments(story_id, search_string)
      temp = 'not found'
      @all_comments[story_id].each do |comment|
        if !comment.text.nil? && (comment.text.downcase.include? search_string)
          temp = comment.text
          break
        end
      end
      result = temp
    end
  end

  class BadCardManager
    attr_accessor :missing_prod_label, :missing_sys_label, :missing_criteria, :other_issues

    def initialize
      @missing_prod_label = []
      @missing_sys_label = []
      @missing_criteria = []
      @other_issues = []
    end

    def add_card(card)
      case card.type
      when MISSING_PROD_TYPE
        @missing_prod_label.push(card)
      when MISSING_SYS_LABEL_TYPE
        @missing_sys_label.push(card)
      when MISSING_CRITERIA_TYPE
        @missing_criteria.push(card)
      when OTHER_ISSUE_TYPE
        @other_issues.push(card)
      else
        puts 'Card not valid type.'
      end
    end
  end

  class BadCard
    attr_accessor :type, :title, :link, :message

    def initialize(type = 0, title = 'Default title', link = 'Default link', message = nil)
      @type = type
      @title = title
      @link = link
      @message = message
    end
  end
end
