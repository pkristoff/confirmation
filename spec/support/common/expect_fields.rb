# frozen_string_literal: true

# MethodCommon
#
module ExpectFields
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders

    # expect a date field
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:field_name</tt>
    # * <tt>:field_id</tt>
    # * <tt>:value</tt>
    # * <tt>:disabled</tt>
    # * <tt>:visible</tt>
    # * <tt>:pre_selector</tt> constraint of where field is located
    #
    def expect_have_field_date(rendered_or_page, field_name, field_id, value, disabled, visible, pre_selector = '')
      expect(rendered_or_page).to have_field(field_name, disabled: disabled, visible: visible, count: 1)
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=date][id=#{field_id}][value='#{value}']") if visible
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=date][id=#{field_id}]") unless visible
    end

    # expect a text field
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:field_name</tt>
    # * <tt>:field_id</tt>
    # * <tt>:value</tt>
    # * <tt>:disabled</tt>
    # * <tt>:visible</tt>
    # * <tt>:pre_selector</tt> constraint of where field is located
    #
    def expect_have_field_text(rendered_or_page, field_name, field_id, value, disabled, visible, pre_selector = '')
      expect(rendered_or_page).to have_field(field_name, disabled: disabled, count: 1, id: field_id, visible: visible)
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=text][id=#{field_id}][value='#{value}']") if visible
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=text][id=#{field_id}]") unless visible
    end
  end
end
