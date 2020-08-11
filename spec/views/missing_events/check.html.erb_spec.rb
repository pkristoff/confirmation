# frozen_string_literal: true

describe 'orphaneds/check.html.erb' do
  include ViewsHelpers
  describe 'orphaned tests' do
    it 'layout with no errors' do
      @orphaneds = Orphaneds.new

      render

      expect_message(nil, nil, rendered)

      # rubocop:disable Layout/LineLength
      section_info = [
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
    end
  end
end
