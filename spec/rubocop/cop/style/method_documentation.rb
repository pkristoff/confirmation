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
        MSG_PARAMETERS_DOES_MATCH_MATCH = "Parameters does not match '#{PARMS_DOC}' exactly."
        MSG_RETURNS_DOES_NOT_MATCH = "Returns does not match '#{RETURNS_DOC}' exactly."
        MSG_ATTRIBUTES_AND_PARAMETERS_NO_COEXIST = 'Attributes and Parameters should not exist on same method.'
        MSG_ILLEGAL_RANGE_RET_BODY_FORMAT = "Illegal %s format: '# * <tt>{CLASS}</tt> {description}'."
        MSG_ILLEGAL_RANGE_BODY_FORMAT = "Illegal %s format: '# * <tt>:{argument}</tt> {description}'."
        MSG_ILLEGAL_RANGE_BODY_FORMAT_SUB = "Illegal %s sub-format: '# **(*) <code>:{value}</code> {description}'."
        MSG_RANGE_BODY_EMPTY = '%s body is empty.'

        #   https://regex101.com/
        DOC_PARM_REGEXP = %r{^# \* <tt>:(\w+)</tt>}.freeze
        DOC_RET_REGEXP = %r{^# \* <tt>([:\w]+)</tt>}.freeze
        DOC_SUB_PARM_REGEXP = %r{^# \** <code>([\.:\w ]+-*[\.:\w ]+)<\/code>([\.:\w ]*-*[\.:\w ]*)}.freeze
        RETURNS_REGEXP = /^[ ]*#[ ]*===[ ]*Returns:[ ]*/.freeze
        ATTR_REGEXP = /^[ ]*#[ ]*===[ ]*Attributes:/.freeze
        PARMS_REGEXP = /^[ ]*#[ ]*===[ ]*Parameters:/.freeze

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

          add_offense(preceding_lines[0], message: MSG_MISSING_DESCRIPTION) if description_range.nil?

          # order
          #   description_range
          #   parameters_range || attrs_range
          #   returns_range
          #
          add_offense(description_range.start_comment, message: MSG_DESCRIPTIION_SHOULD_BE_FIRST) unless description_range.before?(parameters_range) && description_range.before?(returns_range) && description_range.before?(attrs_range)
          add_offense(description_range.start_comment, message: MSG_RETURNS_SHOULD_BE_LAST) unless parameters_range.before?(returns_range) && attrs_range.before?(returns_range)

          add_offense(attrs_range.start_comment, message: MSG_ATTRIBUTES_AND_PARAMETERS_NO_COEXIST) unless attrs_range.missing? || parameters_range.missing?

          index = -1
          special_comm = preceding_lines.any? do |comment|
            index += 1
            !annotation?(comment) &&
              !interpreter_directive_comment?(comment) &&
              !rubocop_directive_comment?(comment)
          end

          return add_offense(preceding_lines[index], message: MSG_INVALID_DOCUMENTATION) unless special_comm

          add_offense(parameters_range.start_comment, message: MSG_PARAMETERS_SHOULD_BE_BEFORE_RETURNS) unless parameters_range.before?(returns_range)

          check_blank_comments(description_range, parameters_range, returns_range, attrs_range)

          args = node.arguments
          return add_offense(preceding_lines[0], message: MSG_MISSING_PARAMETERS) if parameters_range.missing? && !args.empty?
          return add_offense(parameters_range.start_comment, message: MSG_UNNECESSARY_PARAMETERS) if !parameters_range.missing? && args.empty?

          check_body(parameters_range) unless parameters_range.missing?
          check_body(attrs_range) unless attrs_range.missing?
          check_body(returns_range) unless returns_range.missing?

          check_parms_and_args(args, parameters_range) unless parameters_range.missing?
        end

        def check_parms_and_args(args, parameters_range)
          # pns = parm_names(range_lines(preceding_lines, parameters_range))
          pns = parameters_range.parm_names

          add_offense(pns[args.size][0], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if pns.size > args.size
          add_offense(args[pns.size], message: format(MSG_PARAMETERS_ARG_SIZE_MISMATCH, pns.size, args.size)) if args.size > pns.size

          match_parms_to_args(args, pns)
        end

        def check_body(range)
          # puts "check_body=#{range.type} for #{@method_name}"
          # puts range.start_comment.text
          body = range.range_body
          found = false
          body.each_with_index do |line, _i|
            # puts "check_body loop text=#{line.text}"
            next if range.empty_comm?(line)

            found = true
            text = line.text.to_s
            if range.returns?
              # puts "check_body ret DOC_RET_REGEXP) text=#{DOC_RET_REGEXP.match(text)}"
              # puts "check_body (DOC_SUB_PARM_REGEXP) text=#{DOC_SUB_PARM_REGEXP.match(text)}"
              unless DOC_RET_REGEXP.match(text) || DOC_SUB_PARM_REGEXP.match(text)
                add_offense(line, message: format(MSG_ILLEGAL_RANGE_RET_BODY_FORMAT, range.type)) unless text.start_with?('# **')
                add_offense(line, message: format(MSG_ILLEGAL_RANGE_BODY_FORMAT_SUB, range.type)) if text.start_with?('# **')
              end
            else
              # puts "check_body DOC_PARM_REGEXP) text=#{DOC_PARM_REGEXP.match(text)}"
              # puts "check_body (DOC_SUB_PARM_REGEXP) text=#{DOC_SUB_PARM_REGEXP.match(text)}"
              unless DOC_PARM_REGEXP.match(text) || DOC_SUB_PARM_REGEXP.match(text)
                add_offense(line, message: format(MSG_ILLEGAL_RANGE_BODY_FORMAT, range.type)) unless text.start_with?('# **')
                add_offense(line, message: format(MSG_ILLEGAL_RANGE_BODY_FORMAT_SUB, range.type)) if text.start_with?('# **')
              end
            end
          end
          # puts "check_body found=#{found}"
          # puts "check_body adding_offense=#{found}" unless found
          add_offense(range.start_comment, message: format(MSG_RANGE_BODY_EMPTY, range.type)) unless found
        end

        def check_blank_comments(description_range, parameters_range, returns_range, attrs_range)
          unless description_range.missing?
            add_offense(description_range.start_comment, message: MSG_DESCRIPTION_SHOULD_NOT_BEGIN_WITH_BLANK_COMMENT) if description_range.starts_with_empty_comment?
            add_offense(description_range.end_comment, message: MSG_DESCRIPTION_SHOULD_END_WITH_BLANK_COMMENT) unless description_range.ends_with_empty_comment?
          end

          add_offense(parameters_range.start_comment, message: MSG_PARAMETERS_IS_MISSING_FIRST_BLANK_COMMENT) unless parameters_range.first_empty_comment?
          add_offense(parameters_range.end_comment, message: MSG_PARAMETERS_SHOULD_END_WITH_BLANK_COMMENT) unless parameters_range.ends_with_empty_comment?

          add_offense(returns_range.start_comment, message: MSG_RETURNS_IS_MISSING_FIRST_BLANK_COMMENT) unless returns_range.first_empty_comment?
          add_offense(returns_range.end_comment, message: MSG_RETURNS_SHOULD_END_WITH_BLANK_COMMENT) unless returns_range.ends_with_empty_comment?

          add_offense(attrs_range.start_comment, message: MSG_ATTRIBUTES_IS_MISSING_FIRST_BLANK_COMMENT) unless attrs_range.first_empty_comment?
          add_offense(attrs_range.end_comment, message: MSG_ATTRIBUTES_SHOULD_END_WITH_BLANK_COMMENT) unless attrs_range.ends_with_empty_comment?
        end

        def parse_documentation(comments)
          desc = MethodDocRange.new(comments, 'Description')
          returns = MethodDocRange.new(comments, 'Return')
          parms = MethodDocRange.new(comments, 'Parameter')
          attrs = MethodDocRange.new(comments, 'Attribute')
          current = nil
          comments.each_with_index do |comment_line, i|
            text_line = comment_line.text
            if RETURNS_REGEXP.match?(text_line)
              current.end = i - 1 unless current.nil?
              returns.start = i # [comment_line, i, 0]
              current = returns
            elsif PARMS_REGEXP.match?(text_line)
              current.end = i - 1 unless current.nil?
              parms.start = i # [comment_line, i, 0]
              current = parms
            elsif ATTR_REGEXP.match?(text_line)
              current.end = i - 1 unless current.nil?
              attrs.start = i # [comment_line, i, 0]
              current = attrs
            elsif i == 0
              current.end = i - 1 unless current.nil?
              desc.start = i # [comment_line, i, 0]
              current = desc
            end
            current.end = comments.size - 1
          end
          add_offense(comments[0], message: MSG_MISSING_DESCRIPTION) if desc.missing? # !parms.first_comment? && !returns.first_comment?
          unless parms.missing?
            add_offense(parms.start_comment, message: MSG_PARAMETERS_DOES_MATCH_MATCH) unless parms.first_comment_equal?(PARMS_DOC)
          end
          unless returns.missing?
            add_offense(returns.start_comment, message: MSG_RETURNS_DOES_NOT_MATCH) unless returns.first_comment_equal?(RETURNS_DOC)
          end
          unless attrs.missing?
            add_offense(attrs.start_comment, message: MSG_RETURNS_DOES_NOT_MATCH) unless attrs.first_comment_equal?(ATTRS_DOC)
          end
          # puts 'parse_document result'
          # puts("    desc =#{desc.to_s}")
          # puts("    parms=#{parms.to_s}")
          # puts("    returns=#{returns.to_s}")
          # puts("    attrs=#{attrs.to_s}")
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
      end
    end
  end
end

class MethodDocRange
  attr_accessor(:end, :start, :type)

  DOC_PARM_REGEXP = %r{^# \* <tt>:(\w+)</tt>}.freeze
  PARM_START = '# * <tt>:'
  PARM_END = '</tt>'

  def initialize(comments, type)
    @comments = comments
    @type = type
  end

  def before?(method_doc_range)
    return true if missing? || method_doc_range.missing?

    @start < method_doc_range.start
  end

  def empty_comm?(comment)
    txt = comment.text
    txt.size <= 2
  end

  def end_comment
    @comments[@end]
  end

  def ends_with_empty_comment?
    missing? || empty_comm?(end_comment)
  end

  def first_comment?
    @start == 0
  end

  def first_empty_comment?
    missing? || empty_comm?(@comments[@start + 1])
  end

  def first_comment_equal?(text)
    !missing? && start_comment.text == text
  end

  def missing?
    @start.nil?
  end

  def parm_names
    names = []
    range_body.each do |parm_line|
      # puts "parm_line.text=#{parm_line}"
      # puts "match=#{DOC_PARM_REGEXP.match(parm_line.text).to_s}"
      DOC_PARM_REGEXP.match(parm_line.text) do |m|
        parm_name = m.to_s[PARM_START.size...m.to_s.index(PARM_END)]
        names.push([parm_line, parm_name])
        # puts "parm_name=#{parm_name}"
      end
    end
    # puts "names=#{names}"
    names
  end

  def range_body
    @comments[@start + (first_empty_comment? ? 2 : 1)...@end + (ends_with_empty_comment? ? 0 : 1)]
  end

  def returns?
    @type == 'Return'
  end

  def start_comment
    @comments[@start]
  end

  def starts_with_empty_comment?
    empty_comm?(@comments[@start])
  end

  def to_s
    [missing? ? nil : start_comment, @start, @end]
  end
end
