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

        MSG_DOCUMENTATION = 'Missing public method documentation comment for `%<method>s`.'.freeze
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

        MSG_MISSING_DOCUMENTATION = 'Missing public method documentation comment for `%s`.'.freeze
        MSG_INVALID_DOCUMENTATION = 'Invalid public method documentation comment for `%s`.'.freeze
        MSG_MISSING_DESCRIPTION = 'Description is missing for `%s`'.freeze
        MSG_MISSING_PARAMETERS = 'Parameter is missing for `%s`.'.freeze
        MSG_UNNECESSARY_PARAMETERS = 'Unncessary Parameter documentation for `%s`.'.freeze
        MSG_PARAMETERS_MISSING_BLANK_LINE = 'Parameter should have one blankline before arguments for `%s`.'.freeze
        MSG_PARAMETERS_ARG_SIZE_MISMATCH = 'Parameter size `%s` does not match argument size `%s`.'.freeze
        MSG_PARAMETERS_ARG_NAME_MISMATCH = 'Parameter name `%s` does not match argument name `%s`.'.freeze

        def add_format(message)
          format(message, @method_name)
        end

        def add_offense(node, location: :expression, message: nil, severity: nil)
          super(node, location: location, message: add_format(message), severity: severity)
        end

        def prk_documentation_comment(node)
          @method_name = node.children.first.to_s
          # puts "  processing: #{@method_name}"
          preceding_lines = preceding_lines(node)

          return add_offense(node, message: MSG_MISSING_DOCUMENTATION) unless preceding_comment?(node, preceding_lines.last)

          index = -1
          special_comm = preceding_lines.any? do |comment|
            index += 1
            !annotation?(comment) &&
              !interpreter_directive_comment?(comment) &&
              !rubocop_directive_comment?(comment)
          end

          return add_offense(preceding_lines[index], message: MSG_INVALID_DOCUMENTATION) unless special_comm

          desc, nxt = description(preceding_lines, 0)
          return add_offense(preceding_lines[0], message: MSG_MISSING_DESCRIPTION) if desc.empty?

          args = node.arguments
          # puts "  desc.size=#{desc.size} nxt=#{nxt}"
          parms, nxt = parameters(preceding_lines, nxt, args)
          return add_offense(preceding_lines[0], message: MSG_MISSING_PARAMETERS) if parms.empty? && !args.empty?
          return add_offense(parms[0], message: MSG_UNNECESSARY_PARAMETERS) if !parms.empty? && args.empty?

          # puts "  XXX parms.size=#{parms.size}"
          # parms.each do |x|
          #   puts x.text
          # end

          return if parms.empty?

          add_offense(parms[1], message: MSG_PARAMETERS_MISSING_BLANK_LINE) unless empty_comm?(parms[1]) && !empty_comm?(parms[2])

          pns = parm_names(parms[2..parms.size])

          first_parm_index = 2
          add_offense(parms[first_parm_index + (pns.size - args.size)], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if pns.size > args.size
          add_offense(args[args.size - pns.size], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if args.size > pns.size

          match_parms_to_args(args, pns)

          # add_offense(node)
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

        DOC_PARM_REGEXP = /^# \* <tt>_(\w+)_<\/tt>/i
        PARM_START = '# * <tt>_'
        PARM_END = '_</tt>'

        def parm_names(parms)
          parms.map do |parm_line|
            # puts "match=#{DOC_PARM_REGEXP.match(parm_line.text).to_s}"
            parm_name = ''
            DOC_PARM_REGEXP.match(parm_line.text) do |m|
              parm_name = m.to_s[PARM_START.size...m.to_s.index(PARM_END)]
            end
            # puts "parm_name=#{parm_name}"
            [parm_line, parm_name]
            # return add_offense(parm_line, message: 'Ill formed parameter comment') unless /# \* <tt>_W_<\/tt>/.parm_line
          end
        end

        def empty_comm?(comment)
          txt = comment.text
          txt.size <= 2
        end

        def parameters(comments, start, args)
          # puts "  parameters-comments.size=#{comments.size} start=#{start}"
          index = start
          parms = []
          skip_blank = true
          return [parms, index] if index >= comments.size || !empty_comm?(comments[index])
          index += 1
          while index < comments.size && (skip_blank || !empty_comm?(comments[index]))
            skip_blank = false if empty_comm?(comments[index]) && skip_blank
            parms.push(comments[index])
            index += 1
          end
          [parms, index]
        end

        def description(comments, start)
          index = start
          descs = []
          return [descs, start] if empty_comm?(comments[index])
          while index < comments.size && !empty_comm?(comments[index])
            descs.push(comments[index])
            index += 1
          end
          [descs, index]
        end
      end
    end
  end
end
