# frozen_string_literal: true

module RuboCop
  module Cop
    # FIXME
    class Team
      # This is a copy of handle_error in rubocop/cop/team.rb
      # except it raises the error so my tests of my extension will fail
      def handle_error(error, location, cop)
        message = Rainbow("An XXX error occurred while #{cop.name}" \
                           " cop was inspecting #{location}.").red
        @errors << message
        warn message
        if debug?
          puts error.message, error.backtrace
        else
          warn 'To see the complete backtrace run rubocop -d.'
        end
        raise(error)
      end
    end
  end
end
