
class DeployCardCreator
  def create_deploy_card(systems)
    card_description = ''
    systems.each do |systems_label|
      card_description << "#{systems_label}\n"
      systems[systems_label].each do |story|
        card_description << "[#{story.name}](https://www.pivotaltracker.com/story/show/#{story.id})\n"
      end
    end
    puts card_description
  end
end
