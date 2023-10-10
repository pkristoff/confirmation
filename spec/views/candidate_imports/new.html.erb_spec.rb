# frozen_string_literal: true

describe 'candidate_imports/new.html.erb' do
  include ViewsHelpers
  describe 'Non-orphaned tests' do
    before do
      FactoryBot.create(:status)
      FactoryBot.create(:status, name: 'Deferred')
    end

    it 'layout with no errors' do
      @candidate_import = CandidateImport.new

      render

      expect_message(nil, nil, rendered)

      # rubocop:disable Layout/LineLength
      section_info = [
        ['section[id=export] form[id=new_candidate_import][action="/candidate_imports/export_to_excel.xlsx"]', I18n.t('views.imports.excel_no_pict')],
        ['section[id=import] form[id=new_candidate_import][action="/candidate_imports/import_candidates"]', I18n.t('views.imports.import')]
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
      expect(Candidate.count).to be(0)
      expect { @candidate_import.load_initial_file(uploaded_file) }.to raise_error(RuntimeError)

      render

      expect(Candidate.count).to be(0)
    end
  end
end
