
class OtherIssuesChecker < Checker
  def other_issues_check
    @all_stories.each do |story_id, story|
      sys_label_from_commit = get_system_label_from_commit(story_id)
      violation_validation(story_id, story.current_state, sys_label_from_commit)
    end
    return @results
  end
  
  def violation_validation(story_id, state, sys_label_from_commit)
    if state == 'finished' && sys_label_from_commit == 'sysLabelUnknown'
      @results[story_id] = 'Card is marked \'finished\', but has no commits.'
    elsif state == 'delivered' &&
          search_comments(story_id, 'staging acceptance') == 'not found'
      @results[story_id] = 'Card is marked \'delivered\', but doesn\'t have staging acceptance'
    elsif state == 'accepted' &&
          (search_comments(story_id, 'prod acceptance') == 'not found' &&
          sys_label_from_commit != 'sysLabelUnknown') &&
          has_label?(story_id, 'to_prod')
      @results[story_id] = 'Card is marked \'accepted\', but doesn\'t have prod acceptance'
    elsif (state == 'started' || state == 'unstarted') &&
          has_label?(story_id, 'to_prod')
      @results[story_id] = "Card is marked '#{state}', but has the 'to_prod' label."
    end
  end
end
