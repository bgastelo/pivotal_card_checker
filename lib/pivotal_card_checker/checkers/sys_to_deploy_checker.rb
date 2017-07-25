module PivotalCardChecker
  module Checkers
    # Checks the cards to generate a list of the systems that are going to be
    # deployed (determined by the cards labels).
    class SystemsToDeployChecker < SysLabelChecker
      def check
        systems_to_deploy = Hash.new {}
        @all_story_cards.each do |story_card|
          next unless has_label?(story_card.labels, 'to_prod') &&
                      (story_card.current_state == 'finished' ||
                      story_card.current_state == 'delivered')
          sys_labels_on_story = find_system_labels_on_story(story_card.labels)
          sys_labels_on_story.each do |sys_label|
            systems_to_deploy[sys_label] = [] if systems_to_deploy[sys_label].nil?
            systems_to_deploy[sys_label] << story_card
          end
        end
        systems_to_deploy
      end
    end
  end
end
