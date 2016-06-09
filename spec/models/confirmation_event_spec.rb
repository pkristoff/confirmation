require 'rails_helper'

RSpec.describe ConfirmationEvent, type: :model do
  it 'basic creation' do
    confirmation_event = FactoryGirl.create(:confirmation_event)
    expect(confirmation_event.name).to eq('Going out to eat')
    expect(confirmation_event.due_date.to_s).to eq('2016-05-24')
    expect(confirmation_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
  end

  it 'scrubbing instructions' do
    confirmation_event = FactoryGirl.create(:confirmation_event,
                                            instructions: 'ohai! <div>div is safe</div> <script>but script is not</script>')
    expect(confirmation_event.due_date.to_s).to eq('2016-05-24')
    expect(confirmation_event.name).to eq('Going out to eat')
    expect(confirmation_event.instructions.strip).to eq('ohai! <div>div is safe</div>')
  end
end
