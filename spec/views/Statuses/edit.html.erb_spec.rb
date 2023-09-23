# frozen_string_literal: true

Warden.test_mode!

describe 'statuses/edit.html.erb' do
  include Warden::Test::Helpers
  let(:en_locale) { 'en' }
  let(:es_locale) { 'es' }

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  it 'Visit edit status en' do
    render_edit_status en_locale
  end

  it 'Visit edit status es' do
    render_edit_status es_locale
  end

  private

  def render_edit_status(locale)
    I18n.locale = locale
    @status = FactoryBot.create(:status)
    expected_name = @status.name
    expected_description = @status.description
    assign(:model, @status)
    render
    # check to see if gone to admin sign in page
    expect(rendered).to have_selector("h2[id='header']", text: I18n.t('views.statuses.heading.edit'))

    have_css "input[type=text][id=status[name]][value=#{expected_name}]"
    # expect(rendered).to have_field('status[name]',
    #                                type: 'text', text: expected_name)
    expect(rendered).to have_field('status[description]',
                                   type: 'textarea', text: expected_description)

    expect(rendered).to have_button(I18n.t((@status.new_record? ? 'helpers.submit.create' : 'helpers.submit.update'),
                                           model: I18n.t('activerecord.models.status')), count: 1, disabled: false)
  end
end
