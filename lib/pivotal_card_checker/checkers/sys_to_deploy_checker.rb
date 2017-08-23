module PivotalCardChecker
  module Checkers
    # Checks the cards to generate a list of the systems that are going to be
    # deployed (determined by the cards labels).
    class SystemsToDeployChecker < SysLabelChecker

      # Loops through the story cards and adds cards with the 'to_prod' label to
      # either the deployed_cards or cards_to_deploy Hash, depending on current
      # state. Returns the two Hashes.
      def check
        cards_to_deploy = Hash.new { |hash, key| hash[key] = [] }
        deployed_cards = Hash.new { |hash, key| hash[key] = [] }
        @all_story_cards.each do |story_card|
          state = story_card.current_state
          next unless has_label?(story_card.labels, 'to_prod') &&
                      (state == 'finished' || state == 'delivered' ||
                      state == 'accepted')
          if state == 'accepted'
            add_card_to_hash(story_card, deployed_cards)
          else
            add_card_to_hash(story_card, cards_to_deploy)
          end
        end
        [cards_to_deploy, deployed_cards]
      end

      # Adds the given story card to the given Hash.
      def add_card_to_hash(story_card, current_hash)
        sys_labels_on_story = find_system_labels_on_story(story_card.labels)
        sys_labels_on_story.each do |sys_label|
          current_hash[sys_label] << story_card
        end
      end
    end
  end
end
