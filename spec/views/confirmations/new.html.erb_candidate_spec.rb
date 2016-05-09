
describe 'devise/confirmations/new.html.erb' do
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
    # expect(rendered).to have_selector('input[type=submit]', text: 'Reset Password')
    expect(rendered).to have_selector('label[for=candidate_email]', text: 'Email')
    expect(rendered).to have_selector('input[id=candidate_email][value="aaa@bbb.com"]')

    expect(rendered).to have_selector('a[href="/candidates/sign_in"]', text: 'Log in')
    expect(rendered).not_to have_selector('a[href="/candidates/sign_up"]', text: 'Sign up')
    expect(rendered).to have_selector('a[href="/candidates/password/new"]', text: 'Forgot your password?')

  end
end