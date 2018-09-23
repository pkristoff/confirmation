# frozen_string_literal: true

# represents section of mass mailing in the editor and email.
#
class MailPart
  attr_accessor :text
  attr_accessor :name
  attr_accessor :show

  BODY = 'body'
  SUBJECT = 'subject'
  PRE_LATE_INPUT = 'pre_late_input'
  PRE_COMING_DUE_INPUT = 'pre_coming_due_input'
  COMPLETED_AWAITING_INPUT = 'completed_awaiting_input'
  COMPLETED_INPUT = 'completed_input'
  SALUTATION_INPUT = 'salutation_input'
  CLOSING_INPUT = 'closing_input'
  FROM_INPUT = 'from_input'

  # Instantiation for subject
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_body(text, show = true)
    MailPart.new(BODY, text, show)
  end

  # Instantiation for subject
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_subject(text, show = true)
    MailPart.new(SUBJECT, text, show)
  end

  # Instantiation for pre_late_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_pre_late_input(text, show = true)
    MailPart.new(PRE_LATE_INPUT, text, show)
  end

  # Instantiation for pre_coming_due_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_pre_coming_due_input(text, show = true)
    MailPart.new(PRE_COMING_DUE_INPUT, text, show)
  end

  # Instantiation for completed_awaiting_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_completed_awaiting_input(text, show = true)
    MailPart.new(COMPLETED_AWAITING_INPUT, text, show)
  end

  # Instantiation for completed_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_completed_input(text, show = true)
    MailPart.new(COMPLETED_INPUT, text, show)
  end

  # Instantiation for salutation_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_salutation_input(text, show = true)
    MailPart.new(SALUTATION_INPUT, text, show)
  end

  # Instantiation for closing_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_closing_input(text, show = true)
    MailPart.new(CLOSING_INPUT, text, show)
  end

  # Instantiation for from_input
  #
  # === Parameters:
  #
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def self.new_from_input(text, show = true)
    MailPart.new(FROM_INPUT, text, show)
  end

  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:name</tt> field id for tag
  # * <tt>:text</tt> field value
  # * <tt>:show</tt> whether or not to show the div
  #
  def initialize(name, text, show = true)
    @name = name
    @text = text
    @show = show || false
  end

  # I18n lookup key.
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def i18n_label
    "email.#{name}_label"
  end

  # checkbox tag attribute
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def checkbox_name
    "mail[#{name}_check]"
  end

  # section tag attribute
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def section_id
    "section-#{name}"
  end

  # checkbox tag attribute
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def checkbox_checked
    return 'checked=checked' if show
    ''
  end

  # checkbox tag attribute
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def checkbox_value
    show
    # return 'true' if show
    # 'false'
  end

  # output whether to show or hide div
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def section_class
    show ? 'show-div' : 'hide-div'
  end

  # name of input
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def text_area_name
    "mail[#{name}]"
  end
end
