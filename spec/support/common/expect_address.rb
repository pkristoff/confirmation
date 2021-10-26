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
    # * <tt>:values</tt>
    # * <tt>:disabled</tt>
    # * <tt>:blank_fields</tt>
    # * <tt>:visible</tt>
    # * <tt>:form_txt_address</tt>
    #
    def expect_address_fields(rendered_or_page, values, disabled, blank_fields, visible, form_txt_address = '')
      include ExpectFields
      text_fields = %i[street1 street2 city state zip_code]
      text_fields.each do |sym|
        str = sym
        str = 'street_1' if sym == :street1
        str = 'street_2' if sym == :street2
        val = values[str.to_sym]
        val = '' if blank_field?(blank_fields, "label.baptismal_certificate.baptismal_certificate.church_address.#{str}")
        street1_i18_path = 'label.baptismal_certificate.baptismal_certificate.church_address.street_1'
        val = '' if sym == :street2 && blank_field?(blank_fields, street1_i18_path)
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

    def expect_prof_address_fields(rendered_or_page, values, disabled, blank_fields, visible, form_txt_address = '')
      include ExpectFields
      text_fields = %i[street1 street2 city state zip_code]
      text_fields.each do |sym|
        str = sym
        str = 'street_1' if sym == :street1
        str = 'street_2' if sym == :street2
        val = values["prof_#{str}".to_sym]
        val = '' if blank_field?(blank_fields, "label.baptismal_certificate.baptismal_certificate.prof_church_address.prof_#{str}")
        street1_i18_path = 'label.baptismal_certificate.baptismal_certificate.prof_church_address.prof_street_1'
        val = '' if sym == :street2 && blank_field?(blank_fields, street1_i18_path)
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

    # determine if a field should have a value or not
    #
    # === Parameters:
    #
    # * <tt>:fields</tt> blank field error messages
    # * <tt>:i18n_path</tt>
    #
    def blank_field?(fields, i18n_path)
      # 1st part of message is in english the second half is translated
      fields.include? "#{I18n.t(i18n_path, locale: 'en')} #{I18n.t('errors.messages.blank')}"
    end
  end
end
