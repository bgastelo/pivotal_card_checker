
class SysLabelChecker < Checker
  ALL_SYSTEM_LABELS = ['cms', 'billing engine', 'dct', 'reader', 'marketing',
                       'ui', 'pivotal card health tools', 'mailroom'].freeze

  def sys_label_check
    @all_stories.each do |story_id, story|
      next unless is_candidate?(story_id, story.current_state)
      sys_label_on_story = check_labels(story_id)
      sys_label_violation_check(story_id, sys_label_on_story)
    end
    return @results
  end

  def check_labels(story_id)
    unless @all_labels[story_id].nil?
      @all_labels[story_id].each do |label|
        return label.name if ALL_SYSTEM_LABELS.include? label.name
      end
    end
    return 'not found'
  end

  def sys_label_violation_check(story_id, sys_label_on_story)
    sys_label_from_commit = get_system_label_from_commit(story_id)
    if sys_label_on_story == 'not found'
      if sys_label_from_commit == 'sysLabelUnknown'
        @results[story_id] = 'No system labels detected (reader, cms, dct, etc...)'
      else
        @results[story_id] = "Did not find expected label: '#{sys_label_from_commit}'"
      end
    elsif sys_label_from_commit != 'sysLabelUnknown' && !has_label?(story_id, sys_label_from_commit)
      @results[story_id] = "Expected label: '#{sys_label_from_commit}', but found '#{sys_label_on_story}' instead."
    end
  end
end
