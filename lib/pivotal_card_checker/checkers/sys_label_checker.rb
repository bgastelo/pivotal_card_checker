
class SysLabelChecker < Checker
  ALL_SYSTEM_LABELS = ['cms', 'billing engine', 'dct', 'reader', 'marketing',
                       'ui', 'pivotal card health tools', 'mailroom'].freeze

  def sys_label_check
    @all_stories.each do |story_id, story|
      unless candidate?(story_id, story.current_state)
        next
      end
      sys_label_on_story = 'None'
      unless @all_labels[story_id].nil?
        @all_labels[story_id].each do |label|
          if system_label?(label.name)
            sys_label_on_story = label.name
            break
          end
        end
      end
      sys_label_test(story.id, sys_label_on_story)
    end
    return @results
  end

  def sys_label_test(story_id, sys_label_on_story)
    sys_label_from_commit = get_system_label_from_commit(story_id)
    if sys_label_on_story == 'None'
      message = 'No system labels detected (reader, cms, dct, etc...)'
      if sys_label_from_commit != 'sysLabelUnknown'
        message = "Did not find expected label: '#{sys_label_from_commit}'"
      end
      @results[story_id] = message
    elsif sys_label_from_commit != 'sysLabelUnknown' && !has_label?(story_id, sys_label_from_commit)
      @results[story_id] = "Expected label: '#{sys_label_from_commit}', but found '#{sys_label_on_story}' instead."
    end
  end
  
  # Returns true if the given label name is a system label.
  def system_label?(label_name)
    ALL_SYSTEM_LABELS.include? label_name
  end
end
