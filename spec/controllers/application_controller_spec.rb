describe ApplicationController do

  describe 'event_class' do
    context 'confirmation due_date not set' do
      let (:confirmation_event) { FactoryGirl.create(:confirmation_event, due_date: nil) }
      it 'should always return event-unitialized' do
        expect(controller.event_class(FactoryGirl.create(:candidate_event, confirmation_event: confirmation_event))).to eq('event-unitialized')
      end
    end
    context 'confirmation due_date is set' do
      let (:confirmation_event_no_due_date) { FactoryGirl.create(:confirmation_event, due_date: nil) }
      let (:confirmation_event_today) { FactoryGirl.create(:confirmation_event, due_date: Date.today) }
      let (:confirmation_event_today_plus_40) { FactoryGirl.create(:confirmation_event, due_date: Date.today+40) }
      let (:confirmation_event_today_minus_40) { FactoryGirl.create(:confirmation_event, due_date: Date.today-40) }

      let (:candidate_event_not_completed_no_due_date) { FactoryGirl.create(:candidate_event,
                                                                      completed_date: nil,
                                                                      admin_confirmed: false,
                                                                      confirmation_event: confirmation_event_no_due_date) }
      let (:candidate_event_not_completed_today) { FactoryGirl.create(:candidate_event,
                                                                      completed_date: nil,
                                                                      admin_confirmed: false,
                                                                      confirmation_event: confirmation_event_today) }
      let (:candidate_event_not_completed_today_plus_40) { FactoryGirl.create(:candidate_event,
                                                                              completed_date: nil,
                                                                              admin_confirmed: false,
                                                                              confirmation_event: confirmation_event_today_plus_40) }
      let (:candidate_event_not_completed_today_minus_40) { FactoryGirl.create(:candidate_event,
                                                                               completed_date: nil,
                                                                               admin_confirmed: false,
                                                                               confirmation_event: confirmation_event_today_minus_40) }

      let (:candidate_event_not_verified_no_due_date) { FactoryGirl.create(:candidate_event,
                                                                     completed_date: Date.today,
                                                                     admin_confirmed: false,
                                                                     confirmation_event: confirmation_event_no_due_date) }
      let (:candidate_event_not_verified_today) { FactoryGirl.create(:candidate_event,
                                                                     completed_date: Date.today,
                                                                     admin_confirmed: false,
                                                                     confirmation_event: confirmation_event_today) }
      let (:candidate_event_not_verified_today_plus_40) { FactoryGirl.create(:candidate_event,
                                                                             completed_date: Date.today,
                                                                             admin_confirmed: false,
                                                                             confirmation_event: confirmation_event_today_plus_40) }
      let (:candidate_event_not_verified_today_minus_40) { FactoryGirl.create(:candidate_event,
                                                                              completed_date: Date.today,
                                                                              admin_confirmed: false,
                                                                              confirmation_event: confirmation_event_today_minus_40) }

      let (:candidate_event_completed_no_due_date) { FactoryGirl.create(:candidate_event,
                                                                  completed_date: Date.today,
                                                                  admin_confirmed: true,
                                                                  confirmation_event: confirmation_event_no_due_date) }
      let (:candidate_event_completed_today) { FactoryGirl.create(:candidate_event,
                                                                  completed_date: Date.today,
                                                                  admin_confirmed: true,
                                                                  confirmation_event: confirmation_event_today) }
      let (:candidate_event_completed_today_plus_40) { FactoryGirl.create(:candidate_event,
                                                                             completed_date: Date.today,
                                                                             admin_confirmed: true,
                                                                             confirmation_event: confirmation_event_today_plus_40) }
      let (:candidate_event_completed_today_minus_40) { FactoryGirl.create(:candidate_event,
                                                                              completed_date: Date.today,
                                                                              admin_confirmed: true,
                                                                              confirmation_event: confirmation_event_today_minus_40) }
      it 'should always return event-awaiting-candidate' do

        expect(controller.event_class(candidate_event_not_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_completed_today)).to eq('event-awaiting-candidate')
        expect(controller.event_class(candidate_event_not_completed_today_plus_40)).to eq('event-awaiting-candidate')
        expect(controller.event_class(candidate_event_not_completed_today_minus_40)).to eq('event-late')

        expect(controller.event_class(candidate_event_not_verified_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_verified_today)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_plus_40)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_minus_40)).to eq('event-awaiting-verification')

        expect(controller.event_class(candidate_event_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_completed_today)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_plus_40)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_minus_40)).to eq('event-completed')
      end
    end
  end

end