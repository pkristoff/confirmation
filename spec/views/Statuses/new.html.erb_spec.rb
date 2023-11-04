# frozen_string_literal: true

Warden.test_mode!

describe 'statuses/new.html.erb' do
  include Warden::Test::Helpers
  let(:en_locale) { 'en' }
  let(:es_locale) { 'es' }

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  it 'Visit new status en' do
    render_new_status en_locale
  end

  it 'Visit new status es' do
    render_new_status es_locale
  end

  private

  def render_new_status(locale)
    # page.driver.header 'Accept-Language', locale
    I18n.locale = locale
    @status = Status.new

    render

    # check to see if going to admin sign in page
    expect(rendered).to have_selector("h2[id='header']", text: I18n.t('views.statuses.heading.new'))

    expect(rendered).to have_field('status[name]',
                                   type: 'text', text: '')
    expect(rendered).to have_field('status[description]',
                                   type: 'textarea', text: '')

    expect(rendered).to have_button(I18n.t('helpers.submit.create', model: I18n.t('activerecord.models.status')),
                                    count: 1,
                                    disabled: false)
  end
end
