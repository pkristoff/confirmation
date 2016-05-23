require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end


def expect_message id, message
  [:flash_alert, :flash_notice, :error_explanation].each do |my_id|
    unless my_id == id
      expect(page).not_to have_selector("div[id=#{my_id}]")
    end
  end
  expect(page).to have_selector("div[id=#{id}]", text: message)
end