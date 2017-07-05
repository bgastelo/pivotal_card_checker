require "pivotal_card_checker/version"
require "tracker_api"

module PivotalCardChecker
  MISSING_PROD_TYPE = 1
  MISSING_SYS_LABEL_TYPE = 2
  MISSING_CRITERIA_TYPE = 3
  OTHER_ISSUE_TYPE = 4

  class CardChecker
    HEDGEYE_PROJECT_ID = 414867

    def self.checkCards(api_key)
      client = TrackerApi::Client.new(token: api_key)
      hedgeye_project = client.project(HEDGEYE_PROJECT_ID)

      #Stores all bad card info. Maps owner string to BadCardManager.
      bad_card_info = Hash.new

      #Gets the current iteration and all backlog iterations.
      iterations = hedgeye_project.iterations(scope: :current_backlog)

      should_have_to_prod = []
      @all_stories = Hash.new
      @all_labels = Hash.new
      @all_comments = Hash.new
      @all_owners = Hash.new

      iterations.each do |iteration|
        iteration.stories.each do |story|
          curr_id = story.id
          @all_stories[curr_id] = story
          @all_labels[curr_id] = story.labels
          @all_comments[curr_id] = story.comments
          @all_owners[curr_id] = story.owners
        end
      end

      findCandidateStories(should_have_to_prod)
      analyzeCandidates(should_have_to_prod, bad_card_info)
      printReport(bad_card_info)
    end

    def self.findCandidateStories(should_have_to_prod)
      @all_stories.each do |story_id, story|
        state = story.current_state
        if state === "finished" or state === "delivered" or state === "accepted"
          should_have_to_prod.push(story)
        else
          if searchComments(story_id, "Commit by") != "not found"
            should_have_to_prod.push(story)
          end
        end
      end
    end

    def self.analyzeCandidates(should_have_to_prod, bad_card_info)
      should_have_to_prod.each do |story|
        story_id = story.id
        card_owners = getOwners(story_id)
        if story.current_state === "accepted"
          if (searchComments(story_id, "prod acceptance") === "not found" and
            getSystemLabelFromCommit(story_id) != "sysLabelUnknown")
            if bad_card_info[card_owners].nil?
              bad_card_info[card_owners] = BadCardManager.new
            end
              bad_card_info[card_owners].addCard(BadCard.new(OTHER_ISSUE_TYPE, story.name,
              "https://www.pivotaltracker.com/story/show/#{story_id}",
              "Card is marked 'accepted', but doesn't have prod acceptance"))
          end
          next
        end
        has_prod_label = false
        has_sys_label = false
        needs_criteria = true
        sys_label_detected = "None"
        sys_lable_from_commit = getSystemLabelFromCommit(story_id)
        temp = []

        @all_labels[story_id].each do |label|
          if label.name === "to_prod"
            has_prod_label = true
          elsif label.name === "not_to_prod" or label.name === "delayed_prod"
            has_prod_label = true
            needs_criteria = false
          end
          if isSystemLabel(label.name)
            sys_label_detected = label.name
            has_sys_label = true
          end
        end

        #If the card doesn't have a to_prod label.
        if !has_prod_label
          temp.push(BadCard.new(MISSING_PROD_TYPE, story.name,
          "https://www.pivotaltracker.com/story/show/#{story_id}"))
        elsif needs_criteria and (story.current_state === "finished" or story.current_state === "delivered")
          message = "None"
          if !hasAcceptanceCriteria(story_id)
            message = "No acceptance criteria in desciption or comments."
          elsif hasLabel(story_id, "criteria needed")
            message = "'criteria needed' label was detected."
          end

          if message != "None"
            temp.push(BadCard.new(MISSING_CRITERIA_TYPE, story.name,
            "https://www.pivotaltracker.com/story/show/#{story_id}", message))
          end
        end

        if !has_sys_label
          message = "No system labels detected (reader, cms, dct, etc...)"
          if sys_lable_from_commit != "sysLabelUnknown"
            message = "Did not find expected label: '#{sys_label}'"
          end

          temp.push(BadCard.new(MISSING_SYS_LABEL_TYPE, story.name,
          "https://www.pivotaltracker.com/story/show/#{story_id}", message))
=begin
          else
            #message about missing label
            story.add_label(sys_label)
            story.save
            puts "ADDED #{sys_label} to: #{story.name}"
=end
        else
          if sys_lable_from_commit != "sysLabelUnknown" and !hasLabel(story_id, sys_label)
            temp.push(BadCard.new(MISSING_SYS_LABEL_TYPE, story.name,
            "https://www.pivotaltracker.com/story/show/#{story_id}",
            "Expected label: '#{sys_label}', but found '#{sys_label_detected}' instead."))
          end
        end

        if story.current_state === "finished" and sys_lable_from_commit === "sysLabelUnknown"
          temp.push(BadCard.new(OTHER_ISSUE_TYPE, story.name,
          "https://www.pivotaltracker.com/story/show/#{story_id}",
          "Card is marked 'finished', but has no commits."))
        elsif story.current_state === "delivered" and searchComments(story_id, "staging acceptance") === "not found"
          temp.push(BadCard.new(OTHER_ISSUE_TYPE, story.name,
          "https://www.pivotaltracker.com/story/show/#{story_id}",
          "Card is marked 'delivered', but doesn't have staging acceptance"))
        end

        if temp.length > 0
          if bad_card_info[card_owners].nil?
            bad_card_info[card_owners] = BadCardManager.new
          end
          temp.each do |card|
            bad_card_info[card_owners].addCard(card)
          end
        end
      end
    end

    def self.printReport(bad_card_info)
      puts "\n========= Results ==========="
      if bad_card_info.length == 0
        puts "CONGRATS! No card violations."
      else
        bad_card_info.each do |owner_name, card_manager|
          puts "OWNER(s): #{owner_name}"
          if card_manager.missing_prod_label.length > 0
            puts "        Missing prod description label ('to_prod', 'delayed_prod', or 'not_to_prod'):"
            card_manager.missing_prod_label.each do |card|
              puts "                #{card.title} - #{card.link}"
            end
          end

          if card_manager.missing_sys_label.length > 0
            puts "        Missing system label:"
            card_manager.missing_sys_label.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end

          if card_manager.missing_criteria.length > 0
            puts "        Missing acceptance criteria:"
            card_manager.missing_criteria.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end

          if card_manager.other_issues.length > 0
            puts "        Other issues:"
            card_manager.other_issues.each do |card|
              puts "                #{card.title} - #{card.link} - #{card.message}"
            end
          end
          puts "\n"
        end
      end
    end

    #Returns a comma seperated list of all the story's owners.
    def self.getOwners(story_id)
      owner_names = []
      @all_owners[story_id].each do |person|
        owner_names.push(person.name)
      end

      owner_names.join(", ")
    end

    #Returns true if the given label name is a system label.
    def self.isSystemLabel(labelName)
      labelName === "cms" or labelName === "billing engine" or labelName === "dct" or
      labelName === "reader" or labelName === "marketing" or labelName === "ui" or
      labelName === "pivotal card health tools" or labelName === "mailroom"
    end

    def self.getSystemLabelFromCommit(story_id)
      temp = "sysLabelUnknown"
      searchResult = searchComments(story_id, "github.com/")

      if searchResult != "not found"
        temp = searchResult.split(/github.com\/(.*?)\/(.*?)\/commit/)[2]
        if temp.include? "hedgeye-"
          temp = temp[8...temp.length]
        end
        temp.gsub!('_', ' ')
      end
      result = temp
    end

    def self.hasAcceptanceCriteria(story_id)
      story = @all_stories[story_id]
      hasCriteria = false

      #Check in labels for 'criteria approved'
      if hasLabel(story_id, "criteria approved")
        hasCriteria = true;
      #Check for acceptance criteria in card descrption.
      elsif !story.description.nil? and story.description.downcase.include? "acceptance criteria"
        hasCriteria = true
      #Criteria not found in description, check comments.
      else
        if searchComments(story_id, "acceptance criteria") != "not found"
          hasCriteria = true
        end
      end
      temp = hasCriteria
    end

    def self.hasLabel(story_id, label_looking_for)
      found = false
      @all_labels[story_id].each do |label|
        if label.name === label_looking_for
          found = true
          break
        end
      end
      result = found
    end

    def self.searchComments(story_id, searchString)
      temp = "not found"
      @all_comments[story_id].each do |comment|
        if !comment.text.nil? and comment.text.downcase.include? searchString
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

    def addCard(card)
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
        puts "Card not valid type."
      end
    end
  end

  class BadCard
    attr_accessor :type, :title, :link, :message

    def initialize(type = 0, title = "Default title", link = "Default link", message = nil)
      @type = type
      @title = title
      @link = link
      @message = message
    end
  end
end
