
class ProdInfoChecker < Checker
  def prod_check
    missing_prod_info = []

    @all_stories.each do |story_id, story|
      if is_candidate?(story_id, story.current_state) &&
         !has_label?(story_id, 'to_prod') &&
         !has_label?(story_id, 'delayed_prod') &&
         !has_label?(story_id, 'not_to_prod')
        missing_prod_info.push(story_id)
      end
    end
    return missing_prod_info
  end
end
