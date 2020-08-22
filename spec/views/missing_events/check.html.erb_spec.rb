# frozen_string_literal: true

describe 'missing_events/check.html.erb' do
  include ViewsHelpers
  describe 'orphaned tests' do
    it 'layout with no errors' do
      @missing_events = MissingEvents.new

      render

      expect_message(nil, nil, rendered)

      # rubocop:disable Layout/LineLength
      expect(rendered).to have_selector('section[id=check-missing-events] form[id=new_missing_events][action="/missing_events/check"]')
      section_info = [
        t('views.missing_events.check'),
        t('views.missing_events.add_missing')
      ]
      # rubocop:enable Layout/LineLength

      section_info.each do |info|
        expect(rendered).to have_button(info)
      end

      # reason for "- 1" is orphaned-table-rows repeated
      expect(rendered).to have_selector('section', count: section_info.length - 1)
    end
  end
end
