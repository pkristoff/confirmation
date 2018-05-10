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

        ATTRS_DOC = '# === Attributes:'
        RETURNS_DOC = '# === Returns:'
        PARMS_DOC = '# === Parameters:'

        MSG_DOCUMENTATION = 'Missing public method documentation comment for `%<method>s`.'
        MSG_MISSING_DOCUMENTATION = 'Missing public method documentation comment for `%s`.'
        MSG_INVALID_DOCUMENTATION = 'Invalid public method documentation comment for `%s`.'
        MSG_MISSING_DESCRIPTION = 'Description is missing for `%s`.'
        MSG_MISSING_PARAMETERS = 'Parameter is missing for `%s`.'
        MSG_UNNECESSARY_PARAMETERS = 'Unnecessary Parameter documentation for `%s`.'
        MSG_PARAMETERS_MISSING_BLANK_LINE = 'Parameter should have one blankline before arguments for `%s`.'
        MSG_PARAMETERS_ARG_SIZE_MISMATCH = 'Parameter size `%s` does not match argument size `%s`.'
        MSG_PARAMETERS_ARG_NAME_MISMATCH = 'Parameter name `%s` does not match argument name `%s`.'
        MSG_DESCRIPTION_SHOULD_NOT_BEGIN_WITH_BLANK_COMMENT = 'Description should not begin with blank comment.'
        MSG_DESCRIPTION_SHOULD_END_WITH_BLANK_COMMENT = 'Description should end with blank comment.'
        MSG_PARAMETERS_IS_MISSING_FIRST_BLANK_COMMENT = '=== Parameters: should have a blank comment following it.'
        MSG_PARAMETERS_SHOULD_END_WITH_BLANK_COMMENT = 'Parameters should end with blank comment.'
        MSG_ATTRIBUTES_IS_MISSING_FIRST_BLANK_COMMENT = '=== Attributes: should have a blank comment following it.'
        MSG_ATTRIBUTES_SHOULD_END_WITH_BLANK_COMMENT = 'Attributes: should end with a blank comment.'
        MSG_RETURNS_IS_MISSING_FIRST_BLANK_COMMENT = '=== Returns: should have a blank comment following it.'
        MSG_RETURNS_SHOULD_END_WITH_BLANK_COMMENT = 'Returns should end with blank comment.'
        MSG_RETURNS_SHOULD_BE_LAST = 'Returns should be last.'
        MSG_DESCRIPTIION_SHOULD_BE_FIRST = 'description should be first.'
        MSG_PARAMETERS_SHOULD_BE_BEFORE_RETURNS = 'Parameters should be before Returns.'
        MSG_NO_DESC = 'No description'
        MSG_PARAMETERS_DOES_MATCH_MATCH = "Parameters does not match '#{PARMS_DOC}' exactly."
        MSG_RETURNS_DOES_NOT_MATCH = "Returns does not match '#{RETURNS_DOC}' exactly."
        MSG_ATTRIBUTES_AND_PARAMETERS_NO_COEXIST = 'Attributes and Parameters should not exist on same method.'

        DOC_PARM_REGEXP = %r{^# \* <tt>:(\w+)</tt>}i
        PARM_START = '# * <tt>:'
        PARM_END = '</tt>'
        RETURNS_REGEXP = /^[ ]*#[ ]*===[ ]*Returns:[ ]*/i
        ATTR_REGEXP = /^[ ]*#[ ]*===[ ]*Attributes:/i
        PARMS_REGEXP = /^[ ]*#[ ]*===[ ]*Parameters:/i

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

          description_range, parameters_range, returns_range, attrs_range = parse_documentation(preceding_lines)

          add_offense(preceding_lines[0], message: MSG_MISSING_DESCRIPTION) if description_range.empty?

          # order
          #   description_range
          #   parameters_range || attrs_range
          #   returns_range
          #
          add_offense(description_range[0], message: MSG_DESCRIPTIION_SHOULD_BE_FIRST) unless before(description_range, parameters_range) && before(description_range, returns_range) && before(description_range, attrs_range)
          add_offense(description_range[0], message: MSG_RETURNS_SHOULD_BE_LAST) unless before(parameters_range, returns_range) && before(attrs_range, returns_range)

          add_offense(attrs_range[0], message: MSG_ATTRIBUTES_AND_PARAMETERS_NO_COEXIST) unless attrs_range.empty? || parameters_range.empty?

          index = -1
          special_comm = preceding_lines.any? do |comment|
            index += 1
            !annotation?(comment) &&
              !interpreter_directive_comment?(comment) &&
              !rubocop_directive_comment?(comment)
          end

          return add_offense(preceding_lines[index], message: MSG_INVALID_DOCUMENTATION) unless special_comm

          add_offense(parameters_range[0], message: MSG_PARAMETERS_SHOULD_BE_BEFORE_RETURNS) unless before(parameters_range, returns_range)

          check_blank_comments(preceding_lines, description_range, parameters_range, returns_range, attrs_range)

          args = node.arguments
          return add_offense(preceding_lines[0], message: MSG_MISSING_PARAMETERS) if parameters_range.empty? && !args.empty?
          return add_offense(parameters_range[0], message: MSG_UNNECESSARY_PARAMETERS) if !parameters_range.empty? && args.empty?

          return if parameters_range.empty?

          pns = parm_names(preceding_lines[parameters_range[1]...parameters_range[2] + 1])

          add_offense(pns[args.size][0], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if pns.size > args.size
          add_offense(args[pns.size], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if args.size > pns.size

          match_parms_to_args(args, pns)
        end

        def check_blank_comments(preceding_lines, description_range, parameters_range, returns_range, attrs_range)
          unless description_range.empty?
            add_offense(description_range[0], message: MSG_DESCRIPTION_SHOULD_NOT_BEGIN_WITH_BLANK_COMMENT) if empty_comm?(preceding_lines[description_range[1]])
            add_offense(preceding_lines[description_range[2]], message: MSG_DESCRIPTION_SHOULD_END_WITH_BLANK_COMMENT) unless empty_comm?(preceding_lines[description_range[2]])
          end

          add_offense(preceding_lines[parameters_range[1]], message: MSG_PARAMETERS_IS_MISSING_FIRST_BLANK_COMMENT) unless parameters_range.empty? || empty_comm?(preceding_lines[parameters_range[1] + 1])
          add_offense(preceding_lines[parameters_range[2]], message: MSG_PARAMETERS_SHOULD_END_WITH_BLANK_COMMENT) unless parameters_range.empty? || empty_comm?(preceding_lines[parameters_range[2]])

          add_offense(preceding_lines[returns_range[1]], message: MSG_RETURNS_IS_MISSING_FIRST_BLANK_COMMENT) unless returns_range.empty? || empty_comm?(preceding_lines[returns_range[1] + 1])
          add_offense(preceding_lines[returns_range[2]], message: MSG_RETURNS_SHOULD_END_WITH_BLANK_COMMENT) unless returns_range.empty? || empty_comm?(preceding_lines[returns_range[2]])

          add_offense(preceding_lines[attrs_range[1]], message: MSG_ATTRIBUTES_IS_MISSING_FIRST_BLANK_COMMENT) unless attrs_range.empty? || empty_comm?(preceding_lines[attrs_range[1] + 1])
          add_offense(preceding_lines[attrs_range[2]], message: MSG_ATTRIBUTES_SHOULD_END_WITH_BLANK_COMMENT) unless attrs_range.empty? || empty_comm?(preceding_lines[attrs_range[2]])
        end

        def parse_documentation(comments)
          desc = []
          returns = []
          parms = []
          attrs = []
          current = []
          comments.each_with_index do |comment_line, i|
            text_line = comment_line.text
            if RETURNS_REGEXP.match(text_line)
              current[2] = i - 1 unless current.empty?
              returns = [comment_line, i, 0]
              current = returns
            elsif PARMS_REGEXP.match(text_line)
              current[2] = i - 1 unless current.empty?
              parms = [comment_line, i, 0]
              current = parms
            elsif ATTR_REGEXP.match(text_line)
              current[2] = i - 1 unless current.empty?
              attrs = [comment_line, i, 0]
              current = attrs
            elsif i == 0
              current[2] = i - 1 unless current.empty?
              desc = [comment_line, i, 0]
              current = desc
            end
            current[2] = comments.size - 1
          end
          add_offense(comments[0], message: MSG_NO_DESC) if !parms.empty? && parms[1] <= 1 && !returns.empty? && returns[1] <= 1
          unless parms.empty?
            add_offense(parms[0], message: MSG_PARAMETERS_DOES_MATCH_MATCH) unless parms[0].text == PARMS_DOC
          end
          unless parms.empty?
            add_offense(parms[0], message: MSG_PARAMETERS_DOES_MATCH_MATCH) unless parms[0].text == PARMS_DOC
          end
          unless returns.empty?
            add_offense(returns[0], message: MSG_RETURNS_DOES_NOT_MATCH) unless returns[0].text == RETURNS_DOC
          end
          unless attrs.empty?
            add_offense(attrs[0], message: MSG_RETURNS_DOES_NOT_MATCH) unless attrs[0].text == ATTRS_DOC
          end
          # puts 'parse_document result'
          # puts("    desc =#{desc}")
          # puts("    parms=#{parms}")
          # puts("    returns=#{returns}")
          # puts("    attrs=#{attrs}")
          [desc, parms, returns, attrs]
        end

        def match_parms_to_args(args, pns)
          pns.each_with_index do |param_pair, i|
            break if args[i].nil?
            arg_name = get_arg_name(args[i])
            param_line = param_pair[0]
            param_name = param_pair[1]
            # puts "Comparing arg name #{arg_name} with parm name #{param_name} ans=#{param_name == arg_name}"
            add_offense(param_line, message: format(MSG_PARAMETERS_ARG_NAME_MISMATCH, param_name, arg_name)) unless param_name == arg_name
          end
        end

        def get_arg_name(arg)
          name = arg.node_parts[0].to_s
          # handle unused arguments, which begin with _
          return name[1...name.size] if name[0] == '_'
          name
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
