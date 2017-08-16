module PivotalCardChecker
  module Checkers
    ALL_SYSTEM_LABELS = ['cms', 'billing engine', 'dct', 'reader', 'marketing',
                         'pivotal card health tools', 'mailroom',
                         'talk to the cards', 'retail-data', 'macro monitor'].freeze
    ALL_SYS_LABEL_IDS = [2_162_869, 3_091_513, 11_686_698, 2_359_297, 2_090_081,
                         18_741_299, 2_713_317, 7_254_766, 13_055_644, 12_244_398].freeze
    # Generic Checker class that contains attributes and methods that are used
    # by multiple *_checker classes.
    class Checker
      def initialize(all_story_cards)
        @all_story_cards = all_story_cards
        @results = Hash.new {}
      end

      def check
        puts 'Generic check method.'
      end

      def has_commits?(comments)
        has_comment_that_contains?('Commit by', comments, true)
      end

      def get_system_label_from_commit(comments)
        search_results = find_all_comments_that_contain('github.com/', comments)
        system_labels_detected = Set.new

        search_results.each do |current_comment|
          temp = current_comment.split(%r{/github.com\/(.*?)\/(.*?)\/})[2]
          temp = temp[8...temp.length] if temp.include? 'hedgeye-'
          system_labels_detected << temp.tr('_', ' ') if ALL_SYSTEM_LABELS.include? temp.tr('_', ' ')
        end
        system_labels_detected.to_a
      end

      def has_label?(labels, label_looking_for)
        unless labels.nil?
          labels.each do |label|
            return true if label.name == label_looking_for
          end
        end
        false
      end

      def has_comment_that_contains?(search_string, comments,
                                     case_sensitive = false)
        comments.each do |comment|
          return true if !comment.text.nil? && (!case_sensitive &&
             (comment.text.downcase.include? search_string.downcase) ||
             case_sensitive && (comment.text.include? search_string))
        end
        false
      end

      def find_all_comments_that_contain(search_string, comments)
        valid_comments = []
        comments.each do |comment|
          valid_comments << comment.text if !comment.text.nil? &&
                                            (comment.text.include? search_string)
        end
        valid_comments
      end

      def is_candidate?(story_card)
        state = story_card.current_state
        (state == 'finished' || state == 'delivered' || (state == 'accepted' &&
        has_commits?(story_card.comments))) && !has_label?(story_card.labels, 'not_to_prod')
      end
    end
  end
end
