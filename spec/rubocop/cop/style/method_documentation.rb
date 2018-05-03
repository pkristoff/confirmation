# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for missing public method documentation of
      # classes and modules. Classes with no body are exempt from the
      # check and so are namespace modules - modules that have nothing in
      # their bodies except classes, other modules, or constant definitions.
      #
      # The documentation requirement is annulled if the class or module has
      # a "#:nodoc:" comment next to it. Likewise, "#:nodoc: all" does the
      # same for all its children.
      #
      # @example
      #   # bad
      #   class Person
      #     # ...
      #   end
      #
      #   # good
      #   # Description/Explanation of Person class
      #   class Person
      #     # ...
      #   end
      #
      class PublicMethodDocumentation < Cop
        include DocumentationComment
        include DefNode

        #
        # def_node_matcher :constant_definition?, '{class module}'
        # def_node_search :outer_module, '(const (const nil? _) _)'

        def on_def(node)
          # puts("start-#{node.children.first.to_s}")
          method_name, = *node
          check(node)
          # puts 'end-on_def'
        end

        private

        def check(node)
          return if non_public?(node)
          # return if documentation_comment?(node)
          prk_documentation_comment(node)
        end

        def require_for_non_public_methods?
          cop_config['RequireForNonPublicMethods']
        end

        private
        RETURNS_DOC = '# === Returns:'.freeze
        PARMS_DOC = '# === Parameters:'.freeze

        MSG_DOCUMENTATION = 'Missing public method documentation comment for `%<method>s`.'.freeze
        MSG_MISSING_DOCUMENTATION = 'Missing public method documentation comment for `%s`.'.freeze
        MSG_INVALID_DOCUMENTATION = 'Invalid public method documentation comment for `%s`.'.freeze
        MSG_MISSING_DESCRIPTION = 'Description is missing for `%s`'.freeze
        MSG_MISSING_PARAMETERS = 'Parameter is missing for `%s`.'.freeze
        MSG_UNNECESSARY_PARAMETERS = 'Unncessary Parameter documentation for `%s`.'.freeze
        MSG_PARAMETERS_MISSING_BLANK_LINE = 'Parameter should have one blankline before arguments for `%s`.'.freeze
        MSG_PARAMETERS_ARG_SIZE_MISMATCH = 'Parameter size `%s` does not match argument size `%s`.'.freeze
        MSG_PARAMETERS_ARG_NAME_MISMATCH = 'Parameter name `%s` does not match argument name `%s`.'.freeze
        MSG_DESCRIPTION_SHOULD_NOT_BEGIN_WITH_BLANK_COMMENT = 'Description should not begin with blank comment'.freeze
        MSG_DESCRIPTION_SHOULD_NOT_END_WITH_BLANK_COMMENT = 'Description should end with blank comment'.freeze
        MSG_PARAMETERS_SHOULD_NOT_END_WITH_BLANK_COMMENT = 'Parameters should end with blank comment'.freeze
        MSG_RETURNS_SHOULD_NOT_END_WITH_BLANK_COMMENT = 'Returns should end with blank comment'.freeze
        MSG_DESCRIPTIION_SHOULD_BE_FIRST = 'description should be first'.freeze
        MSG_PARAMETERS_SHOULD_BE_BEFORE_RETURNS = 'Parameters should be before Returns'.freeze
        MSG_NO_DESC = 'No description'.freeze
        MSG_PARAMETERZ_DOES_MATCH_MATCH = "Parameters does not match '#{PARMS_DOC}' exactly"
        MSG_RETURNS_DOES_NOT_MATCH = "Returns does not match '#{RETURNS_DOC}' exactly"

        DOC_PARM_REGEXP = /^# \* <tt>:(\w+)<\/tt>/i.freeze
        PARM_START = '# * <tt>:'.freeze
        PARM_END = '</tt>'.freeze
        RETURNS_REGEXP = /^[ ]*#[ ]*===[ ]*Returns:[ ]*/i.freeze
        PARMS_REGEXP = /^[ ]*#[ ]*===[ ]*Parameters:/i.freeze

        def add_format(message)
          format(message, @method_name)
        end

        def add_offense(node, location: :expression, message: nil, severity: nil)
          super(node, location: location, message: add_format(message), severity: severity)
        end

        def before(beg1, beg2)
          return true if beg1.empty? || beg2.empty?
          beg1[1] < beg2[1]
        end

        def prk_documentation_comment(node)
          @method_name = node.children.first.to_s
          # puts "  processing: #{@method_name}"
          preceding_lines = preceding_lines(node)

          return add_offense(node, message: MSG_MISSING_DOCUMENTATION) unless preceding_comment?(node, preceding_lines.last)

          description_range, parameters_range, returns_range = parse_documentation(preceding_lines)

          add_offense(description_range[0], message: MSG_DESCRIPTIION_SHOULD_BE_FIRST) unless before(description_range, parameters_range) && before(description_range, returns_range)

          finish_range(description_range, parameters_range, preceding_lines, returns_range)

          index = -1
          special_comm = preceding_lines.any? do |comment|
            index += 1
            !annotation?(comment) &&
              !interpreter_directive_comment?(comment) &&
              !rubocop_directive_comment?(comment)
          end

          return add_offense(preceding_lines[index], message: MSG_INVALID_DOCUMENTATION) unless special_comm

          add_offense(parameters_range[0], message: MSG_PARAMETERS_SHOULD_BE_BEFORE_RETURNS) unless before(parameters_range, returns_range)

          check_blank_comments(preceding_lines, description_range, parameters_range, returns_range)


          args = node.arguments
          return add_offense(preceding_lines[0], message: MSG_MISSING_PARAMETERS) if parameters_range.empty? && !args.empty?
          return add_offense(parameters_range[0], message: MSG_UNNECESSARY_PARAMETERS) if !parameters_range.empty? && args.empty?

          return if parameters_range.empty?

          pns = parm_names(preceding_lines[parameters_range[1]...parameters_range[2] + 1])

          add_offense(pns[args.size][0], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if pns.size > args.size
          add_offense(args[pns.size], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if args.size > pns.size

          match_parms_to_args(args, pns)

        end

        def check_blank_comments(preceding_lines, description_range, parameters_range, returns_range)
          unless description_range.empty?
            add_offense(description_range[0], message: MSG_DESCRIPTION_SHOULD_NOT_BEGIN_WITH_BLANK_COMMENT) if empty_comm?(preceding_lines[description_range[1]])
            add_offense(preceding_lines[description_range[2]], message: MSG_DESCRIPTION_SHOULD_NOT_END_WITH_BLANK_COMMENT) unless empty_comm?(preceding_lines[description_range[2]])
          end

          add_offense(preceding_lines[parameters_range[2]], message: MSG_PARAMETERS_SHOULD_NOT_END_WITH_BLANK_COMMENT) unless parameters_range.empty? || empty_comm?(preceding_lines[parameters_range[2]])

          add_offense(preceding_lines[returns_range[2]], message: MSG_RETURNS_SHOULD_NOT_END_WITH_BLANK_COMMENT) unless returns_range.empty? || empty_comm?(preceding_lines[returns_range[2]])
        end

        def finish_range(description_range, parameters_range, preceding_lines, returns_range)
          unless description_range.empty?
            if parameters_range.empty?
              if returns_range.empty?
                description_range[2] = preceding_lines.size - 1
              else
                description_range[2] = returns_range[1] - 1
              end
            else
              if before(parameters_range, returns_range)
                description_range[2] = parameters_range[1] - 1
              else
                description_range[2] = returns_range[1] - 1
              end
            end
          end

          unless parameters_range.empty?
            if description_range.empty?
              if before(parameters_range, returns_range)
                if returns_range.empty?
                  parameters_range[2] = preceding_lines.size - 1
                else
                  parameters_range[2] = returns_range[1] - 1
                end
              else
                parameters_range[2] = preceding_lines.size - 1
              end
            else
              if before(parameters_range, returns_range)
                if returns_range.empty?
                  parameters_range[2] = preceding_lines.size - 1
                else
                  parameters_range[2] = returns_range[1] - 1
                end
              else
                parameters_range[2] = preceding_lines.size - 1
              end
            end
          end

          unless returns_range.empty?
            if description_range.empty?
              if before(parameters_range, returns_range)
                returns_range[2] = parameters_range.size - 1
              else
                returns_range[2] = preceding_lines.size - 1
              end
            else
              if before(parameters_range, returns_range)
                if parameters_range.empty?
                  returns_range[2] = preceding_lines.size - 1
                else
                  returns_range[2] = parameters_range[1] - 1
                end
              else
                returns_range[2] = description_range[1] - 1
              end
            end
          end
          # puts "finish_range result"
          # puts("    description_range =#{description_range}")
          # puts("    parameters_range=#{parameters_range}")
          # puts("    returns_range=#{returns_range}")
        end


        def parse_documentation(comments)
          desc = []
          returns = []
          parms = []
          comments.each_with_index do |comment_line, i|
            text_line = comment_line.text
            RETURNS_REGEXP.match(text_line) do |_matchdata|
              returns = [comment_line, i, nil]
            end
            PARMS_REGEXP.match(text_line) do |_matchdata|
              parms = [comment_line, i, nil]
            end
          end
          if (!parms.empty?) && parms[1] <= 1 && (!returns.empty?) && returns[1] <= 1
            add_offense(comments[0], message: MSG_NO_DESC)
          else
            desc = [comments[0], 0, nil]
          end
          unless parms.empty?
            add_offense(parms[0], message: MSG_PARAMETERZ_DOES_MATCH_MATCH) unless parms[0].text == PARMS_DOC
          end
          unless returns.empty?
            add_offense(returns[0], message: MSG_RETURNS_DOES_NOT_MATCH) unless returns[0].text == RETURNS_DOC
          end
          [desc, parms, returns]
        end

        def match_parms_to_args(args, pns)
          pns.each_with_index do |param_pair, i|
            break if args[i].nil?
            arg_name = args[i].node_parts[0].to_s
            param_line = param_pair[0]
            param_name = param_pair[1]
            # puts "Comparing arg name #{arg_name} with parm name #{param_name} ans=#{param_name == arg_name}"
            add_offense(param_line, message: format(MSG_PARAMETERS_ARG_NAME_MISMATCH, param_name, arg_name)) unless param_name == arg_name
          end
        end

        def parm_names(parms)
          names = []
          parms.each do |parm_line|
            # puts "parm_line.text=#{parm_line}"
            # puts "match=#{DOC_PARM_REGEXP.match(parm_line.text).to_s}"
            DOC_PARM_REGEXP.match(parm_line.text) do |m|
              parm_name = m.to_s[PARM_START.size...m.to_s.index(PARM_END)]
              names.push([parm_line, parm_name])
              # puts "parm_name=#{parm_name}"
            end
          end
          names
        end

        def empty_comm?(comment)
          txt = comment.text
          txt.size <= 2
        end
      end
    end
  end
end
