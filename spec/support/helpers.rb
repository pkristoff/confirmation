require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Features::SessionHelpers
end


def expect_message(id, message, rendered_page=page)
  [:flash_alert, :flash_notice, :error_explanation].each do |my_id|
    unless my_id == id
      expect(rendered_page).not_to have_selector("div[id=#{my_id}]")
    end
  end
  if id == :error_explanation and message.is_a? Array
    expect(rendered_page).to have_selector("div[id=#{id}] h2", text: message[0])
    2..message.size do |i|
      expect(rendered_page).to have_selector("div[id=#{id}] li", text: message[i])
    end
  else
    expect(rendered_page).to have_selector("div[id=#{id}]", text: message) unless id.nil?
  end
end

def event_with_picture_setup(route)

  @candidate = FactoryGirl.create(:candidate)
  # AppFactory.add_confirmation_event(event_name) unless event_name.nil?
  if @is_dev
    login_as(@candidate, scope: :candidate)

    @path = dev_event_with_picture_path(@candidate.id, route)
    @dev = 'dev/'
  else
    login_as(FactoryGirl.create(:admin), scope: :admin)

    @path = event_with_picture_path(@candidate.id, route)
    @dev = ''
  end
end

def expect_download_button(name)
  expect(page).to have_selector("form[action=\"/#{@dev}download_document/#{@candidate.id}/.#{name}\"]")
  expect(page).to have_button(I18n.t('views.common.download'))
end

def expect_candidate_event(index, confirmation_event_id, name, the_way_due_date, chs_due_date, instructions, verified, completed_date, id_css = 'fieldset')

  page_or_rendered = (self.respond_to?(:page) ? page : rendered)
  # puts (self.respond_to?(:page) ? page.html : rendered)

  if id_css === 'fieldset'
    name_selector = "fieldset[id=event_id_#{confirmation_event_id}]"
    verified_selector = "candidate_candidate_events_attributes_#{index}_verified"
    completed_selector = "candidate_candidate_events_attributes_#{index}_completed_date"
  else
    name_selector = "div[id=candidate_event_#{confirmation_event_id}_header]"
    verified_selector = "div[id=candidate_event_#{confirmation_event_id}_verified]"
    completed_selector = "div[id=candidate_event_#{confirmation_event_id}_completed_date]"
    if completed_date.empty?
      completed_text = "#{I18n.t('views.events.completed_date')}:#{completed_date}"
    else
      completed_text = "#{I18n.t('views.events.completed_date')}: #{completed_date}"
    end
  end

  expect(page_or_rendered).to have_selector(name_selector, text: name)
  if the_way_due_date.nil?
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: "#{I18n.t('views.events.the_way_due_date')}: #{the_way_due_date}")
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: "#{I18n.t('views.events.chs_due_date')}: #{chs_due_date}")
  else
    expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_the_way_due_date]", text: "#{I18n.t('views.events.the_way_due_date')}: #{the_way_due_date}")
    expect(page_or_rendered).not_to have_selector("div[id=candidate_event_#{confirmation_event_id}_chs_due_date]", text: "#{I18n.t('views.events.chs_due_date')}: #{chs_due_date}")
  end
  # expect(page_or_rendered).to have_selector("div[id=candidate_event_#{index}_instructions]", text: "#{I18n.t('views.events.instructions')}: #{instructions}")
  expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_instructions]", text: "#{I18n.t('views.events.instructions')}:")
  expect(page_or_rendered).to have_selector("div[id=candidate_event_#{confirmation_event_id}_instructions]", text: "#{instructions}")

  if verified
    expect(page_or_rendered).to have_field(verified_selector, checked: true) if id_css === 'fieldset'
  else
    expect(page_or_rendered).to have_field(verified_selector, unchecked: true) if id_css === 'fieldset'
  end
  expect(page_or_rendered).to have_selector(verified_selector, text: "#{I18n.t('views.events.verified')}: #{verified}") unless id_css === 'fieldset'

  if completed_date.empty?
    expect(page_or_rendered).to have_field(completed_selector) if id_css === 'fieldset'
  else
    expect(page_or_rendered).to have_field(completed_selector, with: completed_date.strip) if id_css === 'fieldset'
  end
  expect(page_or_rendered).to have_selector(completed_selector, text: completed_text) unless id_css === 'fieldset'
end