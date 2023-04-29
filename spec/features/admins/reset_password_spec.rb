# frozen_string_literal: true

RSpec.describe 'Reset Admins password' do
  before do
    FactoryBot.create(:visitor) unless Visitor.count > 0
  end

  it 'send reset admin instructions successfully' do
    FactoryBot.create(:admin, email: 'foo@email.com')
    go_to_reset_password_page
    fill_in I18n.t('views.admins.email'), with: 'foo@email.com'
    click_button('Reset Password')
    expect_messages([[:flash_notice, I18n.t('devise.passwords.send_instructions')]])
  end

  it 'unsuccessfully fails because admin does have email address' do
    go_to_reset_password_page
    fill_in I18n.t('views.admins.email'), with: 'retail@kristoffs.com'
    click_button('Reset Password')
    expect_messages([[:flash_alert, I18n.t('messages.flash.alert.admin.reset_password_failed', email: 'retail@kristoffs.com')],
                     [:error_explanation, ['1 error prohibited reset password from being sent:', 'Account name not found']]])
  end

  private

  def go_to_reset_password_page
    visit new_admin_session_path
    click_link('Forgot your password?')
  end
end
