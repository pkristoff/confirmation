# frozen_string_literal: true

describe 'candidate_imports/new.html.erb' do
  include ViewsHelpers
  describe 'Non-orphaned tests' do
    it 'layout with no errors' do
      @candidate_import = CandidateImport.new

      render

      expect_message(nil, nil, rendered)

      # rubocop:disable Layout/LineLength
      section_info = [
        ['section[id=export] form[id=new_candidate_import][action="/candidate_imports/export_to_excel.xlsx"]', I18n.t('views.imports.excel_no_pict')],
        ['section[id=import] form[id=new_candidate_import][action="/candidate_imports/import_candidates"]', I18n.t('views.imports.import')],
        ['section[id=start_new_year] form[id=new_candidate_import][action="/candidate_imports/start_new_year"]', I18n.t('views.imports.reset_database.title')],
        ['section[id=reset_database] form[id=new_candidate_import][action="/candidate_imports/reset_database"]', I18n.t('views.imports.start_new_year.title')]
      ]
      # rubocop:enable Layout/LineLength

      section_info.each do |info|
        expect(rendered).to have_selector(info[0])
        expect(rendered).to have_button(info[1]), "no button found with name: #{info[1]}"
      end

      # reason for "- 1" is orphaned-table-rows repeated
      expect(rendered).to have_selector('section', count: section_info.length)
    end

    it 'layout with errors' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      @candidate_import = CandidateImport.new
      @candidate_import.load_initial_file(uploaded_file)

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
