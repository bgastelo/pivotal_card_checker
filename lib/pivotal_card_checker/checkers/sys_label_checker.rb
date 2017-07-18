module PivotalCardChecker
  module Checkers
    class SysLabelChecker < Checker
      ALL_SYSTEM_LABELS = ['cms', 'billing engine', 'dct', 'reader', 'marketing',
                           'ui', 'pivotal card health tools', 'mailroom'].freeze

      def check
        @all_stories.each do |story_id, story|
          next unless is_candidate?(story_id, story.current_state)
          sys_labels_on_story = find_system_labels_on_story(story_id)
          sys_label_violation_check(story_id, sys_labels_on_story)
        end
        return @results
      end

      def find_system_labels_on_story(story_id)
        sys_labels = Set.new
        unless @all_labels[story_id].nil?
          @all_labels[story_id].each do |label|
            sys_labels.add(label.name) if ALL_SYSTEM_LABELS.include? label.name
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
             if !has_label?(story_id, sys_label)
               @results[story_id] = "Expected label(s): '#{sys_labels_from_comments.join('\', \'')}', but found: '#{sys_labels_on_story.join('\', \'')}' instead."
               break
             end
          end
        end
      end
    end
  end
end