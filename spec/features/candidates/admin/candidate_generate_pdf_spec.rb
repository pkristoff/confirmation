# frozen_string_literal: true

Warden.test_mode!

feature 'Candidate email', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before(:each) do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')
    candidate3 = create_candidate('Karen', 'Louise', 'Kristoff')
    AppFactory.add_confirmation_events
    # re-lookup instances are diff
    @candidate1 = Candidate.find_by(account_name: candidate1.account_name)
    @candidate2 = Candidate.find_by(account_name: candidate2.account_name)
    @candidate3 = Candidate.find_by(account_name: candidate3.account_name)
    @candidates = [@candidate1,
                   @candidate2,
                   @candidate3]
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin generates pdf for no one' do
    visit candidates_path
    click_button('top-update-generate-pdf')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
  end

  scenario 'admin generates pdf for candidate 1' do
    visit candidates_path

    check("candidate_candidate_ids_#{@candidate1.id}")

    click_button('top-update-generate-pdf')
    convert_pdf_to_page
    expect(page).to have_content('2019 Confirmation booklet for Vicki Kristoff')
  end

  def convert_pdf_to_page
    temp_pdf = Tempfile.new('pdf')
    temp_pdf << page.source.force_encoding('UTF-8')
    reader = PDF::Reader.new(temp_pdf)
    pdf_text = reader.pages.map(&:text)
    temp_pdf.close
    page.driver.response.instance_variable_set('@body', pdf_text)
  end

  scenario 'admin tries to generates pdf for 2 candidate' do
    visit candidates_path

    check("candidate_candidate_ids_#{@candidate1.id}")
    check("candidate_candidate_ids_#{@candidate2.id}")

    click_button('top-update-generate-pdf')

    expect_message(:flash_notice, I18n.t('messages.processing_pdf_background', num: 2))
    expect_sorting_candidate_list(
      candidates_columns,
      @candidates,
      page
    )

    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate1.id}")
    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate2.id}")
  end
end
