# frozen_string_literal: true

require 'support/common/expect_fields'
# MethodCommon
#
module ExpectAddress
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include ExpectFields

    # expect address fields
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:bc_form_info</tt>
    # * <tt>:disabled</tt>
    # * <tt>:visible</tt>
    # * <tt>:form_txt_address</tt>
    #
    def expect_address_fields(rendered_or_page, bc_form_info, disabled, visible, form_txt_address = '')
      include ExpectFields
      text_fields = %i[street1 street2 city state zip_code]
      text_fields.each do |sym|
        str = sym
        str = 'street_1' if sym == :street1
        str = 'street_2' if sym == :street2
        val = bc_form_info.field_value(str.to_sym, 'label.baptismal_certificate.baptismal_certificate.church_address')
        street1_i18_path = 'label.baptismal_certificate.baptismal_certificate.church_address.street_1'
        val = '' if sym == :street2 && bc_form_info.blank_field?(street1_i18_path)
        ExpectFields.expect_have_field_text(
          rendered_or_page,
          I18n.t("label.baptismal_certificate.baptismal_certificate.church_address.#{str}"),
          "candidate_baptismal_certificate_attributes_church_address_attributes_#{str}",
          val,
          disabled,
          visible,
          form_txt_address
        )
      end
    end

    # expect profession of faith address fields
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:bc_form_info</tt>
    # * <tt>:disabled</tt>
    # * <tt>:visible</tt>
    # * <tt>:form_txt_address</tt>
    #
    def expect_prof_address_fields(rendered_or_page, bc_form_info, disabled, visible, form_txt_address = '')
      include ExpectFields
      text_fields = %i[street1 street2 city state zip_code]
      text_fields.each do |sym|
        str = sym
        str = 'street_1' if sym == :street1
        str = 'street_2' if sym == :street2
        # rubocop:disable Layout/LineLength
        val = bc_form_info.field_value("prof_#{str}".to_sym, 'label.baptismal_certificate.baptismal_certificate.prof_church_address')
        # rubocop:enable Layout/LineLength
        # if street1 is blank then assume blank2 is blank.
        prof_street1_i18_path = 'label.baptismal_certificate.baptismal_certificate.prof_church_address.prof_street_1'
        val = '' if sym == :street2 && bc_form_info.blank_field?(prof_street1_i18_path)
        ExpectFields.expect_have_field_text(
          rendered_or_page,
          I18n.t("label.baptismal_certificate.baptismal_certificate.prof_church_address.prof_#{str}"),
          "candidate_baptismal_certificate_attributes_prof_church_address_attributes_#{str}",
          val,
          disabled,
          visible,
          form_txt_address
        )
      end
    end
  end
end
