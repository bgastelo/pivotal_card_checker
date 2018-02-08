module PivotalCardChecker
  # Holds the relevant story information.
  class StoryCard
    attr_reader :id, :name, :description, :labels, :comments, :owners, :current_state, :in_current_iteration

    def initialize(id, name, description, labels, comments, owners, current_state, in_current_iteration)
      @id = id
      @name = name.strip
      @description = description
      @labels = labels
      @comments = comments
      @owners = owners
      @current_state = current_state
      @in_current_iteration = in_current_iteration
    end

    # Checks if the list of comments has the text 'Commit by' (case-sensitive),
    # which is posted when a merge occurs. (Ex. Commit by Steve,
    # https://github.com/...)
    def has_commits?
      has_comment_that_contains?('Commit by', true)
    end

    # Looks through all of the comments, finds commit comments, and gets the
    # system label from the github URL.
    def get_system_label_from_commit
      search_results = find_all_comments_that_contain('github.com/')
      system_labels_detected = Set.new

      search_results.each do |current_comment|
        temp = current_comment.split(%r{/github.com\/(.*?)\/(.*?)\/})[2]
        temp = temp[8...temp.length] if temp.include? 'hedgeye-'
        system_labels_detected << temp.tr('_', ' ') if ALL_SYSTEM_LABELS.include? temp.tr('_', ' ')
      end
      system_labels_detected.to_a
    end

    # Checks if a list of labels (labels) contains the label we're looking
    # for (label_looking_for).
    def has_label?(label_looking_for)
      unless @labels.nil?
        @labels.each do |label|
          return true if label.name == label_looking_for
        end
      end
      false
    end

    # Looks through a list of comments (comments) for a string (search_string),
    # case sensitivity (case_sensitive) is set to false by default.
    def has_comment_that_contains?(search_string, case_sensitive = false)
      @comments.each do |comment|
        return true if !comment.text.nil? && (!case_sensitive &&
                                              (comment.text.downcase.include? search_string.downcase) ||
                                              case_sensitive && (comment.text.include? search_string))
      end
      false
    end

    # Returns a list of comment strings that contain the search_string.
    def find_all_comments_that_contain(search_string)
      valid_comments = []
      @comments.each do |comment|
        valid_comments << comment.text if !comment.text.nil? &&
                                          (comment.text.include? search_string)
      end
      valid_comments
    end

    # Checks if a story card has acceptance criteria. First it checks if the
    # card has the label 'criteria approved', then it checks if the 'description'
    # has the text 'acceptance criteria', and lastly, it checks if the card
    # has a comment that contains the text 'acceptance criteria'.
    def has_acceptance_criteria?
      # Check for 'criteria approved' label
      has_label?('criteria approved') ||
        # Check for acceptance criteria in card descrption.
        (!@description.nil? &&
         (@description.downcase.include? 'acceptance criteria')) ||
        # Criteria not found in description, check comments.
        has_comment_that_contains?('acceptance criteria')
    end

    # Returns an array of system labels that were found on the story card.
    def find_system_labels_on_story
      sys_labels = Set.new
      unless @labels.nil?
        @labels.each do |label|
          sys_labels << label.name if ALL_SYSTEM_LABELS.include? label.name
        end
      end
      sys_labels.to_a
    end

    # Returns a list of epic labels, from the labels list.
    def find_epic_labels_on_story(epic_labels_list)
      epic_labels = []
      unless @labels.nil?
        @labels.each do |label|
          epic_labels << label.name if epic_labels_list.include? label.name
        end
      end
      epic_labels
    end
  end
end
