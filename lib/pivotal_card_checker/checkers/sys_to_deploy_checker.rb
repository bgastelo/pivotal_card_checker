
class SystemsToDeployChecker < SysLabelChecker
  def find_systems_to_deploy
    systems_to_deploy = Set.new
    @all_stories.each do |story_id, story|
      if has_label?(story_id, 'to_prod')
        systems_to_deploy.add(check_labels(story_id))
      end
    end
    return systems_to_deploy
  end
end
