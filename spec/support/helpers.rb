# frozen_string_literal: true

require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Features::SessionHelpers
end

def expect_messages(messages, rendered_page = page)
  ids = messages.map { |mp| mp[0] }
  %i[flash_alert flash_notice error_explanation].each do |my_id|
    expect(rendered_page).not_to have_selector("div[id=#{my_id}]") unless ids.include? my_id
  end

  messages.each do |message_pair|
    id = message_pair[0]
    message = message_pair[1]
    if id == :error_explanation && message.is_a?(Array)
      expect(rendered_page).to have_selector("div[id=#{id}] h2", text: message[0])
      (1..message.size).each do |i|
        expect(rendered_page).to have_selector("div[id=#{id}] li", text: message[i])
      end
    else
      expect(rendered_page).to have_selector("div[id=#{id}]", text: message) unless id.nil?
    end
  end
end

def expect_message(id, message, rendered_page = page)
  %i[flash_alert flash_notice error_explanation].each do |my_id|
    expect(rendered_page).not_to have_selector("div[id=#{my_id}]") unless my_id == id
  end
  if (id == :error_explanation) && message.is_a?(Array)
    expect(rendered_page).to have_selector("div[id=#{id}] h2", text: message[0])
    2..message.size do |i|
      expect(rendered_page).to have_selector('li', text: message[i])
    end
  else
    expect(rendered_page).to have_selector("div[id=#{id}]", text: message) unless id.nil?
  end
end

def event_with_picture_setup(route, is_verify = false)
  @candidate = FactoryBot.create(:candidate, add_new_confirmation_events: false)
  if @is_dev
    login_as(@candidate, scope: :candidate)

    @path = dev_event_with_picture_path(@candidate.id, route)
    @dev = 'dev/'
  else
    login_as(FactoryBot.create(:admin), scope: :admin)

    @path = is_verify ? event_with_picture_verify_path(@candidate.id, route) : event_with_picture_path(@candidate.id, route)
    @dev = ''
  end
end

def expect_download_button(name, cand_id, dev_path)
  expect(page).to have_selector("form[action=\"/#{dev_path}download_document/#{cand_id}/.#{name}\"]")
  expect(page).to have_button(I18n.t('views.common.download'))
end

def expect_candidate_event(index, confirmation_event_id, name, the_way_due_date, chs_due_date, instructions, verified, completed_date, id_css = 'fieldset')
  page_or_rendered = respond_to?(:page) ? page : rendered

  if id_css == 'fieldset'
    name_selector = "fieldset[id=event_id_#{confirmation_event_id}]"
    verified_selector = "candidate_candidate_events_attributes_#{index}_verified"
    completed_selector = "candidate_candidate_events_attributes_#{index}_completed_date"
  else
    name_selector = "div[id=candidate_event_#{confirmation_event_id}_header]"
    verified_selector = "div[id=candidate_event_#{confirmation_event_id}_verified]"
    completed_selector = "div[id=candidate_event_#{confirmation_event_id}_completed_date]"
    completed_text = completed_date.empty? ? "#{I18n.t('views.events.completed_date')}:#{completed_date}" : "#{I18n.t('views.events.completed_date')}: #{completed_date}"
  end

  expect(page_or_rendered).to have_selector(name_selector, text: name)
  if the_way_due_date.nil?
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: I18n.t('views.events.the_way_due_date'))
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: the_way_due_date.to_s)
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: I18n.t('views.events.chs_due_date'))
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: chs_due_date.to_s)
  else
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: I18n.t('views.events.the_way_due_date'))
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: the_way_due_date.to_s)
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: I18n.t('views.events.chs_due_date'))
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: chs_due_date.to_s)
  end
  # expect(page_or_rendered).to have_selector("div[id=candidate_event_#{index}_instructions]", text: "#{I18n.t('views.events.instructions')}: #{instructions}")
  expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_instructions]", text: "#{I18n.t('views.events.instructions')}:")
  expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_instructions]", text: "#{instructions}:")

  if verified
    expect(page_or_rendered).to have_field(verified_selector, checked: true) if id_css == 'fieldset'
  elsif id_css == 'fieldset'
    expect(page_or_rendered).to have_field(verified_selector, unchecked: true)
  end
  expect(page_or_rendered).to have_selector(verified_selector, text: "#{I18n.t('views.events.verified')}: #{verified}") unless id_css == 'fieldset'

  if completed_date.empty?
    expect(page_or_rendered).to have_field(completed_selector) if id_css == 'fieldset'
  elsif id_css == 'fieldset'
    expect(page_or_rendered).to have_field(completed_selector, with: completed_date.strip)
  end
  expect(page_or_rendered).to have_selector(completed_selector, text: completed_text) unless id_css == 'fieldset'
end

def expect_image_upload(key, picture_column, label)
  expect(page).to have_css("div[id=file-type-message_#{picture_column}]", text: I18n.t('views.common.image_upload_file_types'))
  expect(page).to have_css("input[id=candidate_#{key}_attributes_#{picture_column}][type=file][accept='#{SideBar::IMAGE_FILE_TYPES}']")
  expect(page).to have_css("label[for=candidate_#{key}_attributes_#{picture_column}]", text: label)
end

def expect_remove_button(hidden_id, field)
  expect(page).to have_selector("button[type=button][id=remove-#{field}][class=show-div]", text: I18n.t('views.common.remove_image'))
  expect(page).to have_selector("button[type=button][id=replace-#{field}][class=hide-div]", text: I18n.t('views.common.replace_image'))
  expect(page).to have_selector("input[type=hidden][id=#{hidden_id}][value='']", visible: false)
end

def expect_field(label, value)
  if value.blank?
    expect(page).to have_field(label)
  else
    expect(page).to have_field(label, with: value)
  end
end

def expect_mail_attadchment_upload
  expect(page).to have_css('div[id=file-type-message-id]', text: I18n.t('views.common.mail_upload_file_types'))
  expect(page).to have_css("input[id=mail_attach_file][type=file][accept='#{SideBar::MAIL_ATTACH_FILE_TYPES}']")
  expect(page).to have_css('label[for=mail_attach_file]', text: I18n.t('label.mail.attach_file'))
  expect(page).to have_css('button[id=clear-attach_file]', text: I18n.t('views.common.clear_attach_file'))
end
