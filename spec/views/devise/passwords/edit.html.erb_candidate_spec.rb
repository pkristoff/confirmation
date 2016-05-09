
describe 'devise/passwords/edit.html.erb' do
  before do
    candidate = Candidate.new
    def candidate.pending_reconfirmation?
      true
    end
    def candidate.unconfirmed_email
      'aaa@bbb.com'
    end
    view.stub(:resource).and_return(candidate)
    view.stub(:resource_name).and_return(:candidate)
    view.stub(:devise_mapping).and_return(Devise.mappings[:candidate])
    view.stub(:confirmation_path).and_return('candidate_confirmation_path')
  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_candidate]')
    expect(rendered).to have_selector('input[id=candidate_reset_password_token][type=hidden]')
    expect(rendered).to have_selector('label[for=candidate_password]', text: 'New password')
    expect(rendered).to have_selector('input[id=candidate_password]', text: '')
    expect(rendered).to have_selector('label[for=candidate_password_confirmation]', text: 'Confirm new password')
    expect(rendered).to have_selector('input[id=candidate_password_confirmation]', text: '')
    expect(rendered).to have_selector('input[type=submit][name="commit"][value="Change my Password"]')

  end
end