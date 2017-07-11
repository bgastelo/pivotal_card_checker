
class OtherIssuesChecker < Checker
  def other_issues_check
    @all_stories.each do |story_id, story|
      state = story.current_state
      sys_label_from_commit = get_system_label_from_commit(story_id)
      if state == 'finished' &&
         sys_label_from_commit == 'sysLabelUnknown'
        results[story_id] = 'Card is marked \'finished\', but has no commits.'
      elsif state == 'delivered' &&
            search_comments(story_id, 'staging acceptance') == 'not found'
        results[story_id] = 'Card is marked \'delivered\', but doesn\'t have staging acceptance'
      elsif state == 'accepted' && 
            (search_comments(story_id, 'prod acceptance') == 'not found' &&
            sys_label_from_commit != 'sysLabelUnknown') &&
            has_label?(story_id, 'to_prod')

        results[story_id] = 'Card is marked \'accepted\', but doesn\'t have prod acceptance'
      elsif has_label?(story_id, 'to_prod') # state == 'started' or state == 'unstarted'
        results[story_id] = "Card is #{state}, but has the 'to_prod' label."
      end
    end
    return @results
  end
end
