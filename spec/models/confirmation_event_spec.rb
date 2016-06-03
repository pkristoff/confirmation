require 'rails_helper'

RSpec.describe ConfirmationEvent, type: :model do
    it 'basic creation' do
    confirmation_event = FactoryGirl.create(:confirmation_event)
    expect(confirmation_event.due_date.to_s).to eq('2016-05-24')
    expect(confirmation_event.name).to eq('Going out to eat')
  end
end
