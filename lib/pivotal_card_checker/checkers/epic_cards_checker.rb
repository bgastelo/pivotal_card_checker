module PivotalCardChecker
  module Checkers
    # Moves any cards with an epic label into that epic's list of cards.
    class EpicCardsChecker < Checker
      def initialize(systems, epic_labels, all_labels)
        @systems = systems
        @epic_labels = epic_labels
        @all_labels = all_labels
        @results = Hash.new { |hash, key| hash[key] = [] }
      end

      def check
        @systems.each do |label, stories|
          stories.each do |story|
            epic_labels_on_story = find_epic_labels_on_story(story.id)
            process_labels(epic_labels_on_story, label, story)
          end
        end
        @results
      end

      def find_epic_labels_on_story(story_id)
        epic_labels = []
        unless @all_labels[story_id].nil?
          @all_labels[story_id].each do |label|
            epic_labels << label.name if @epic_labels.include? label.name
          end
        end
        epic_labels
      end

      def process_labels(epic_labels_on_story, sys_label, story)
        if epic_labels_on_story.empty?
          @results[sys_label] << story
        else
          epic_labels_on_story.each do |epic_label|
            @results[epic_label] << story
          end
        end
      end
    end
  end
end
