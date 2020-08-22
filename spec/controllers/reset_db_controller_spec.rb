# frozen_string_literal: true

describe ResetDbController do
  describe 'reset_database' do
    it 'should reset database' do
      expect(Candidate.all.size).to eq(0)
      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)
      expect(ConfirmationEvent.all.size).to eq(2)
      expect(CandidateEvent.all.size).to eq(6)
      expect(ToDo.all.size).to eq(6)
      login_admin

      expect(Admin.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)

      post :reset_database

      expect(response).to redirect_to(root_url)
      candidates = Candidate.all
      expect(candidates.size).to eq(1)

      expect(ConfirmationEvent.all.size).to eq(9)
      expect(CandidateEvent.all.size).to eq(9)
      expect(ToDo.all.size).to eq(9)

      candidate = candidates.first
      expect(candidate.account_name).to eq('vickikristoff')
      candidate_sheets = CandidateSheet.all
      expect(candidate_sheets.size).to eq(1)
      expect(candidate.candidate_sheet).to eq(candidate_sheets.first)
      expect_event_association_local(candidate.baptismal_certificate)
      expect_event_association_local(candidate.candidate_sheet)
      expect_event_association_local(candidate.sponsor_covenant)
      expect_event_association_local(candidate.sponsor_eligibility)
      expect_event_association_local(candidate.pick_confirmation_name)
      expect_event_association_local(candidate.christian_ministry)
      expect_event_association_local(candidate.retreat_verification)

      expect(Admin.all.size).to eq(1)
    end

    it 'should reset database Visitor and Admin are reset' do
      admin = login_admin

      admin.email = 'foo@bar.com'
      admin.contact_name = 'ccc yyy'
      admin.contact_phone = '919-999-9999'
      admin.save

      Visitor.visitor('xxx', '<home></home>', '<about></about>', '919-999-9999')

      post :reset_database

      expect(response).to redirect_to(root_url)

      expect(Visitor.visitor.home_parish).to eq('Change to home parish of confirmation')
      expect(Visitor.visitor.home).to eq('HTML for home page')
      expect(Visitor.visitor.about).to eq('HTML for about page')
      expect(Visitor.visitor.contact).to eq('HTML for contact page')

      admin = Admin.first
      expect(admin.email).to eq('foo@bar.com')
      expect(admin.contact_name).to eq('ccc yyy')
      expect(admin.contact_phone).to eq('919-999-9999')
    end

    it 'should remove all ConfirmationEvent and related ToDo & CandidateEvent' do
      expect(Candidate.all.size).to eq(0)
      expect(ConfirmationEvent.all.size).to eq(0)
      expect(CandidateEvent.all.size).to eq(0)
      expect(ToDo.all.size).to eq(0)

      AppFactory.add_confirmation_events

      expect(Candidate.all.size).to eq(0)
      expect(ConfirmationEvent.all.size).to eq(9)
      expect(CandidateEvent.all.size).to eq(0)
      expect(ToDo.all.size).to eq(0)

      FactoryBot.create(:candidate, account_name: 'a1', add_candidate_events: true, add_new_confirmation_events: false)

      expect(Candidate.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(9)
      expect(CandidateEvent.all.size).to eq(9)
      expect(ToDo.all.size).to eq(9)

      ResetDB.new.remove_all_confirmation_events

      expect(Candidate.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(0)
      expect(ToDo.all.size).to eq(0)
      expect(CandidateEvent.all.size).to eq(0)
    end
  end

  def expect_event_association_local(assoc_from_candidate)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(1)
    expect(assoc_from_candidate).to eq(event_assoc.first)
  end
end
