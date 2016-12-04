# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Replace a pattern in a string expression using another
      # string or a regular expression.
      #
      # Arguments:
      #   "source": the string in which to perform the pattern
      #     replacement
      #   "pattern_type": "string" or "regexp"
      #   "pattern": the pattern to use
      #   "replacement": the string to use to replace the matched
      #     pattern
      class ReplacePattern < Base
        EXPECTED_ARGUMENTS = %w(source pattern_type pattern replacement).freeze
        SUPPORTED_PATTERN_TYPE = %w(string regexp).freeze
        ERR_MSG_PATTERN_TYPE_UNKNOWN = "Unknown pattern type %s"

        def run_after
          ensure_pattern_type_supported!
          send(:"replace_#{pattern_type}")
        end

        private

        def ensure_pattern_type_supported!
          return if SUPPORTED_PATTERN_TYPE.include?(pattern_type)
          raise(Error, format(ERR_MSG_PATTERN_TYPE_UNKNOWN, pattern_type))
        end

        def replace_string
          source.gsub(pattern, replacement)
        end

        def replace_regexp
          source.gsub(Regexp.new(pattern), replacement)
        end
      end
    end
  end
end
