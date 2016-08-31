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
    2..message.size do | i |
      expect(rendered_page).to have_selector("div[id=#{id}] li", text: message[i])
    end
  else
    expect(rendered_page).to have_selector("div[id=#{id}]", text: message) unless id.nil?
  end
end

def event_with_picture_setup(event_name, route)

  @candidate = FactoryGirl.create(:candidate)
  AppFactory.add_confirmation_event(event_name) unless event_name.nil?
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