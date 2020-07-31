# frozen_string_literal: true

describe 'candidate_imports/new.html.erb' do
  include ViewsHelpers
  describe 'Non-orphaned tests' do
    it 'layout with no errors' do
      @candidate_import = CandidateImport.new
      @orphaneds = Orphaneds.new

      render

      expect_message(nil, nil, rendered)

      # rubocop:disable Layout/LineLength
      section_info = [
        ['section[id=export] form[id=new_candidate_import][action="/candidate_imports/export_to_excel.xlsx"]', I18n.t('views.imports.excel_no_pict')],
        ['section[id=import] form[id=new_candidate_import][action="/candidate_imports/import_candidates"]', I18n.t('views.imports.import')],
        ['section[id=start_new_year] form[id=new_candidate_import][action="/candidate_imports/start_new_year"]', I18n.t('views.imports.reset_database.title')],
        ['section[id=reset_database] form[id=new_candidate_import][action="/candidate_imports/reset_database"]', I18n.t('views.imports.start_new_year.title')],
        ['section[id=check_events] form[id=new_candidate_import][action="/candidate_imports/check_events"]', I18n.t('views.imports.check_events')],

        ['section[id=orphaned-table-rows] form[id=new_orphaneds][action="/orphaneds/check"]', I18n.t('views.orphaneds.check_orphaned_table_rows')],
        ['section[id=orphaned-table-rows] form[id=new_orphaneds][action="/orphaneds/remove"]', I18n.t('views.orphaneds.remove_orphaned_table_rows')]
      ]
      # rubocop:enable Layout/LineLength

      section_info.each do |info|
        expect(rendered).to have_selector(info[0])
        expect(rendered).to have_button(info[1]), "no button found with name: #{info[1]}"
      end

      # reason for "- 1" is orphaned-table-rows repeated
      expect(rendered).to have_selector('section', count: section_info.length - 1)

      expect(rendered).to have_button(I18n.t('views.imports.add_missing_events'))

      expect(rendered).to have_selector('div[id=div_missing_confirmation_events] h3', text: I18n.t('views.imports.missing'))
      expect(rendered).to have_selector('div[id=div_missing_confirmation_events] ul[id=missing_confirmation_events]')

      expect(rendered).to have_selector('div[id=div_unknown_confirmation_events] h3', text: I18n.t('views.imports.unknown'))
      expect(rendered).to have_selector('div[id=div_unknown_confirmation_events] ul[id=unknown_confirmation_events]')

      expect(rendered).to have_selector('div[id=div_found_confirmation_events] h3', text: I18n.t('views.imports.found'))
      expect(rendered).to have_selector('div[id=div_found_confirmation_events] ul[id=found_confirmation_events]')

      expect(rendered).to have_selector('section[id=check_events] ul', count: 3)
      expect(rendered).to have_selector('section[id=check_events] li', count: 0)
    end

    it 'layout with errors' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      @candidate_import = CandidateImport.new
      @candidate_import.load_initial_file(uploaded_file)
      @orphaneds = Orphaneds.new

      render

      expect_message(:error_explanation, ['5 errors prohibited this import from completing:',
                                          'Row 2: Last name can\'t be blank',
                                          'Row 3: First name can\'t be blank',
                                          'Row 6: Parent email 1 is an invalid email',
                                          'Row 6: Parent email 2 is an invalid email',
                                          'Row 7: Parent email 1 can\'t be blank'], rendered)
    end
  end
end
