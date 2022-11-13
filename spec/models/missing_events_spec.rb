# frozen_string_literal: true

describe MissingEvents do
  describe 'check_missing_events' do
    include ViewsHelpers
    it 'show "Sponsor Covenant" is missing.' do
      ResetDB.start_new_year
      setup_unknown_missing_events
      missing_events = MissingEvents.new

      missing_events.check_missing_events

      expect(missing_events.missing_confirmation_events.length).to be(1)
      expect(missing_events.missing_confirmation_events[0]).to eq(SponsorCovenant.event_key)
      expect(missing_events.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_keys.length - 1)
      expect(missing_events.unknown_confirmation_events.length).to be(1)
      expect(missing_events.unknown_confirmation_events[0]).to eq('unknown event')
    end

    it 'add "Sponsor Covenant".' do
      ResetDB.start_new_year
      missing_events = MissingEvents.new
      setup_unknown_missing_events
      sponsor_covenant_event_key = SponsorCovenant.event_key

      missing_events.add_missing([sponsor_covenant_event_key])

      expect(ConfirmationEvent.find_by(event_key: sponsor_covenant_event_key).event_key).to eq(sponsor_covenant_event_key)

      expect(missing_events.missing_confirmation_events.length).to be(0)
      expect(missing_events.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_keys.length)
      expect(missing_events.unknown_confirmation_events.length).to be(1)
      expect(missing_events.unknown_confirmation_events[0]).to eq('unknown event')
    end
  end
end
