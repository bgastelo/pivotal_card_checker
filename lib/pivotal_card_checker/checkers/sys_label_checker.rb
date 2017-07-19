module PivotalCardChecker
  module Checkers
    # Verifies the cards to see if any of them are either missing a system
    # label(s) or have an incorrect system label(s).
    class SysLabelChecker < Checker
      def check
        @all_stories.each do |story_id, story|
          next unless is_candidate?(story_id, story.current_state)
          sys_labels_on_story = find_system_labels_on_story(story_id)
          sys_label_violation_check(story_id, sys_labels_on_story)
        end
        @results
      end

      def find_system_labels_on_story(story_id)
        sys_labels = Set.new
        unless @all_labels[story_id].nil?
          @all_labels[story_id].each do |label|
            sys_labels << label.name if ALL_SYSTEM_LABELS.include? label.name
          end
        end
        sys_labels.to_a
      end

      def sys_label_violation_check(story_id, sys_labels_on_story)
        sys_labels_from_comments = get_system_label_from_commit(story_id)
        if sys_labels_on_story.empty?
          if sys_labels_from_comments.empty?
            @results[story_id] = 'No system labels detected (reader, cms, dct, etc...)'
          else
            @results[story_id] = "Did not find expected label(s): '#{sys_labels_from_comments.join('\', \'')}'"
          end
        elsif !sys_labels_from_comments.empty?
          sys_labels_from_comments.each do |sys_label|
            unless has_label?(story_id, sys_label)
              @results[story_id] = "Expected label(s): '#{sys_labels_from_comments.join('\', \'')}', but found: '#{sys_labels_on_story.join('\', \'')}' instead."
              break
            end
          end
        end
      end
    end
  end
end
