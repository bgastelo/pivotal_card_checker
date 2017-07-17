# Generic Checker class that contains attributes and methods that are used
# by multiple *_checker classes.
class Checker
  attr_reader :all_stories, :all_labels, :all_comments, :results

  STORIES_INDEX = 0
  LABELS_INDEX = 1
  COMMENTS_INDEX = 2

  def initialize(lists)
    @all_stories = lists[STORIES_INDEX]
    @all_labels = lists[LABELS_INDEX]
    @all_comments = lists[COMMENTS_INDEX]
    @results = Hash.new {}
  end

  def is_candidate?(story_id, state)
    state == 'finished' || state == 'delivered' || (state == 'accepted' &&
    has_commits?(story_id))
  end

  def has_commits?(story_id)
    has_comment_that_contains?('Commit by', story_id, true)
  end

  def get_system_label_from_commit(story_id)
    search_results = find_all_comments_that_contain('github.com/', story_id)
    system_labels_detected = Set.new {}

    search_results.each do |current_comment|
      temp = current_comment.split(%r{/github.com\/(.*?)\/(.*?)\/})[2]
      temp = temp[8...temp.length] if temp.include? 'hedgeye-'
      system_labels_detected.add(temp.tr('_', ' '))
    end
    system_labels_detected.to_a
  end

  def has_label?(story_id, label_looking_for)
    unless @all_labels[story_id].nil?
      @all_labels[story_id].each do |label|
        return true if label.name == label_looking_for
      end
    end
    return false
  end

  def has_comment_that_contains?(search_string, story_id,
                                 case_sensitive = false)
    @all_comments[story_id].each do |comment|
      return true if !comment.text.nil? && (!case_sensitive &&
         (comment.text.downcase.include? search_string.downcase) ||
         case_sensitive && (comment.text.include? search_string))
    end
    false
  end

  def find_all_comments_that_contain(search_string, story_id)
    valid_comments = []
    @all_comments[story_id].each do |comment|
      valid_comments.push(comment.text) if !comment.text.nil? &&
                                           (comment.text.include? search_string)
    end
    valid_comments
  end
end
