
describe AdminsController do

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  describe 'authentication' do

    it 'should fail authentication' do
      login_candidate
      get :index
      expect(@candidates).to eq(nil)
    end

    it 'should pass authentication and set @admins' do
      login_admin
      get :index
      expect(subject.admins.size).to eq(1)
    end

  end

  describe 'set_confirmation_events' do
    it 'is sorted zero events' do
      controller.set_confirmation_events
      expect(controller.confirmation_events.size).to eq(0)
    end
    it 'is sorted one event' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-24')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.size).to eq(1)
    end
    it 'is sorted two event' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-23')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce1)
      expect(confirmation_events.size).to eq(2)
    end
    it 'is sorted three event' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-23')
      ce3 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce3)
      expect(confirmation_events.second).to eq(ce2)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: one nil' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, due_date: nil)
      ce3 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: two nil' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, due_date: nil)
      ce3 = FactoryGirl.create(:confirmation_event, due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: two nil 2' do
      ce1 = FactoryGirl.create(:confirmation_event, due_date: nil)
      ce2 = FactoryGirl.create(:confirmation_event, due_date: '2016-05-23')
      ce3 = FactoryGirl.create(:confirmation_event, due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce2)
      expect(confirmation_events.size).to eq(3)
    end
  end

end