# frozen_string_literal: true

describe CandidateImportsController do
  describe 'new' do
    it 'should fail authentication' do
      login_candidate
      get :new
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to eq(nil)
    end

    it 'should create a new CandidateImport' do
      login_admin
      get :new
      # expect(response).to render_template('new')
      expect(response.status).to eq(200)
      expect(controller.candidate_import).not_to eq(nil)
    end
  end

  describe 'create' do
    it 'should fail authentication' do
      login_candidate
      post :import_candidates
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to eq(nil)
    end

    it 'should import candidates with valid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(response).to redirect_to(root_url)
      expect(controller.candidate_import).not_to eq(nil)
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'should import candidates with invalid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to eq(nil)
      expect(controller.candidate_import.errors.size).to eq(5)
    end
  end

  describe 'start_new_year' do
    it 'should remove all candidates, changes due date to today, and adds a seed candidate' do
      expect(Candidate.all.size).to eq(0)
      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)
      login_admin

      post :start_new_year

      expect(response).to redirect_to(root_url)
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to be(nil), 'Could not find candidate seed: vickikristoff'
      expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
      expect(ConfirmationEvent.all.size).not_to eq(0)
      ConfirmationEvent.all.each do |ce|
        expect(ce.chs_due_date).to eq(Time.zone.today)
        expect(ce.the_way_due_date).to eq(Time.zone.today)
      end
    end
    it 'It should keep the visitor info the same' do
      Visitor.visitor('xxx', '<home></home>', '<about></about>', '919-999-9999')
      login_admin

      post :start_new_year

      expect(Visitor.visitor.home_parish).to eq('xxx')
      expect(Visitor.visitor.home).to eq('<home></home>')
      expect(Visitor.visitor.about).to eq('<about></about>')
      expect(Visitor.visitor.contact).to eq('919-999-9999')
    end
    it 'It should keep the admins info the same' do
      admin = login_admin
      admin.email = 'foo@bar.com'
      admin.contact_name = 'ccc yyy'
      admin.contact_phone = '919-999-9999'
      admin.save

      post :start_new_year

      ad = Admin.find(admin.id)
      expect(ad.email).to eq('foo@bar.com')
      expect(ad.contact_name).to eq('ccc yyy')
      expect(ad.contact_phone).to eq('919-999-9999')
    end
  end

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

      expect(ConfirmationEvent.all.size).to eq(8)
      expect(CandidateEvent.all.size).to eq(8)
      expect(ToDo.all.size).to eq(8)

      candidate = candidates.first
      expect(candidate.account_name).to eq('vickikristoff')
      candidate_sheets = CandidateSheet.all
      expect(candidate_sheets.size).to eq(1)
      expect(candidate.candidate_sheet).to eq(candidate_sheets.first)
      expect_event_association_local(candidate.baptismal_certificate)
      expect_event_association_local(candidate.candidate_sheet)
      expect_event_association_local(candidate.sponsor_covenant)
      expect_event_association_local(candidate.pick_confirmation_name)
      expect_event_association_local(candidate.christian_ministry)
      expect_event_association_local(candidate.retreat_verification)
      expect_event_association_local(candidate.sponsor_covenant)

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
      expect(ConfirmationEvent.all.size).to eq(8)
      expect(CandidateEvent.all.size).to eq(0)
      expect(ToDo.all.size).to eq(0)

      FactoryBot.create(:candidate, account_name: 'a1', add_candidate_events: true, add_new_confirmation_events: false)

      expect(Candidate.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(8)
      expect(CandidateEvent.all.size).to eq(8)
      expect(ToDo.all.size).to eq(8)

      CandidateImport.new.remove_all_confirmation_events

      expect(Candidate.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(0)
      expect(ToDo.all.size).to eq(0)
      expect(CandidateEvent.all.size).to eq(0)
    end
  end

  describe 'export_to_excel' do
    it 'should bad commit.' do
      login_admin

      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')

      post :export_to_excel, params: { commit: 'bad commit', format: 'xlsx' }

      expect(response.body).to have_css('a[href="http://test.host/candidate_imports/new"]')
    end
  end

  def expect_event_association_local(assoc_from_candidate)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(1)
    expect(assoc_from_candidate).to eq(event_assoc.first)
  end
end
