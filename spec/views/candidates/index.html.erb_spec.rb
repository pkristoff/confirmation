# frozen_string_literal: true

describe 'candidates/index.html.erb' do
  include ViewsHelpers
  before do
    @admin = login_admin
    @admin.table_filter_and_sorting_columns = Admin.initial_sorting_settings
    @admin.save!
    AppFactory.generate_default_status
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have to re-look up candidates because local is diff object than db instance
    @candidates = [Candidate.find_by(account_name: candidate1.account_name),
                   Candidate.find_by(account_name: candidate2.account_name)]
    @candidate_info = PluckCan.pluck_candidates
  end

  it 'display the list of candidates in Spanish' do
    I18n.locale = 'es'

    render

    expect_index_buttons

    expect_sorting_candidate_list(
      candidates_columns,
      @candidates,
      rendered
    )
  end

  it 'display the list of candidates in English' do
    I18n.locale = 'en'

    render

    expect_index_buttons

    expect_sorting_candidate_list(
      candidates_columns,
      @candidates,
      rendered
    )
  end

  it 'display hidden values' do
    render

    expect(rendered).to have_css('#admin_id', visible: :hidden, text: @admin.id.to_s)
    expect(rendered).to have_css('#table_filter_and_sorting_columns_id',
                                 visible: :hidden,
                                 text: @admin.table_filter_and_sorting_columns)
  end

  private

  def expect_index_buttons
    expect(rendered).to have_button(I18n.t('views.common.delete'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.email'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.reset_password'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.initial_email'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.generate_pdf'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.confirm_account'), count: 2)
    expect(rendered).to have_button(I18n.t('views.common.unconfirmed_account'), count: 2)
  end
end
