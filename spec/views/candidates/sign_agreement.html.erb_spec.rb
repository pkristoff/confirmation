include ViewsHelpers

describe 'dev/candidates/sign_agreement.html.erb' do

  before(:each) do

    @candidate = FactoryGirl.create(:candidate)

  end

  it 'Form layout where candidate has not signed confirmation agreement' do

    @candidate.signed_agreement=false

    expect_form_layout(@candidate.signed_agreement)

  end

  it 'Form layout where candidate has signed confirmation agreement' do

    @candidate.signed_agreement=true

    expect_form_layout(@candidate.signed_agreement)

  end

  def expect_form_layout(signed_aggreement)

    render

    expect(rendered).to have_selector("form[id=edit_candidate][action=\"/sign_agreement.#{@candidate.id}\"]")

    expect(rendered).to have_selector("code", text: I18n.t('views.candidates.convenant_agreement'))

    if signed_aggreement
      expect(rendered).to have_checked_field('Signed agreement')
    else
      expect(rendered).not_to have_checked_field('Signed agreement')
    end

    expect(rendered).to have_button(I18n.t('views.common.update'))
  end

  describe 'Form Update' do

    it 'Form layout where candidate has signed confirmation agreement' do

      @candidate.signed_agreement=false

      render

      check('Signed agreement')
    end

  end

end
