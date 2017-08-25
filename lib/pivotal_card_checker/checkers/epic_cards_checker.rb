module PivotalCardChecker
  module Checkers
    # Moves any cards with an epic label into that epic's list of cards.
    class EpicCardsChecker < Checker
      def initialize(systems, epic_labels)
        @systems = systems
        @epic_labels = epic_labels
        @results = Hash.new { |hash, key| hash[key] = [] }
        @epic_results = Hash.new { |hash, key| hash[key] = Hash.new { |hash1, key1| hash1[key1] = [] } }
      end

      # Returns a Hash of cards that are in an epic (@epic_results), and those
      # that are not (@results).
      def check
        @systems.each do |label, story_cards|
          story_cards.each do |story_card|
            epic_labels_on_story = story_card.find_epic_labels_on_story(@epic_labels)
            process_labels(epic_labels_on_story, label, story_card)
          end
        end
        [@results, @epic_results]
      end

      # Places the given story card into the epic_results Hash, or the @results
      # Hash.
      def process_labels(epic_labels_on_story, sys_label, story_card)
        if epic_labels_on_story.empty?
          @results[sys_label] << story_card
        else
          epic_labels_on_story.each do |epic_label|
            @epic_results[epic_label][sys_label] << story_card
          end
        end
      end
    end
  end
end
