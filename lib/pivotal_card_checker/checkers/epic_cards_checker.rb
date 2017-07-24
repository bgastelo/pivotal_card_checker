module PivotalCardChecker
  module Checkers
    # Moves any cards with an epic label into that epic's list of cards.
    class EpicCardsChecker < Checker
      def initialize(systems, epic_labels)
        @systems = systems
        @epic_labels = epic_labels
        @results = Hash.new { |hash, key| hash[key] = [] }
      end

      def check
        @systems.each do |label, story_cards|
          story_cards.each do |story_card|
            epic_labels_on_story = find_epic_labels_on_story(story_card.labels)
            process_labels(epic_labels_on_story, label, story_card)
          end
        end
        @results
      end

      def find_epic_labels_on_story(labels)
        epic_labels = []
        unless labels.nil?
          labels.each do |label|
            epic_labels << label.name if @epic_labels.include? label.name
          end
        end
        epic_labels
      end

      def process_labels(epic_labels_on_story, sys_label, story_card)
        if epic_labels_on_story.empty?
          @results[sys_label] << story_card
        else
          epic_labels_on_story.each do |epic_label|
            @results[epic_label] << story_card
          end
        end
      end
    end
  end
end
