# frozen_string_literal: true

# represents section of mass mailing in the editor and email.
#
class MailPart
  attr_accessor :text
  attr_accessor :name
  attr_accessor :show

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
