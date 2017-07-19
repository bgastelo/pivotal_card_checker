module PivotalCardChecker
  module Checkers
    # Moves any cards with an epic label into that epic's list of cards.
    class EpicCardsChecker < Checker
      def initialize(systems, epic_labels, all_labels)
        @systems = systems
        @epic_labels = epic_labels
        @all_labels = all_labels
        @results = Hash.new {}
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
        epic_labels = Set.new
        unless @all_labels[story_id].nil?
          @all_labels[story_id].each do |label|
            epic_labels.add(label.name) if @epic_labels.include? label.name
          end
        end
        epic_labels.to_a
      end

      def process_labels(epic_labels_on_story, sys_label, story)
        if epic_labels_on_story.empty?
          add_story_to_results(sys_label, story)
        else
          epic_labels_on_story.each do |epic_label|
            add_story_to_results(epic_label, story)
          end
        end
      end

      def add_story_to_results(label, story)
        @results[label] = [] if @results[label].nil?
        @results[label].push(story)
      end
    end
  end
end
