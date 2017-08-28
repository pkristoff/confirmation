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
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.size).to eq(1)
    end
    it 'is sorted two event' do
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce1)
      expect(confirmation_events.size).to eq(2)
    end
    it 'is sorted three event' do
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      ce3 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-29', chs_due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce3)
      expect(confirmation_events.second).to eq(ce2)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: one nil' do
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce3 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-29', chs_due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: two nil' do
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryGirl.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce3 = FactoryGirl.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end
    it 'is sorted three event: two nil 2' do
      ce1 = FactoryGirl.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce2 = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      ce3 = FactoryGirl.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce2)
      expect(confirmation_events.size).to eq(3)
    end
  end

  describe 'mass_edit_candidates_event_update' do

    before(:each) do
      @admdin = login_admin
      @confirmation_event = AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
    end

    it 'should NOT update any candidate\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          completed_date: '2016-09-04',
          verified: true,
          candidate: {candidate_ids: []}

      expect_candidate_event(@c1, '2016-06-09', false)
      expect_candidate_event(@c2, '', false)
      expect_candidate_event(@c3, '2016-07-23', false)
    end
    it 'should update only c2\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          completed_date: '2016-09-04',
          verified: true,
          candidate: {candidate_ids: [@c2.id]}

      expect_candidate_event(@c1, '2016-06-09', false)
      expect_candidate_event(@c2, '2016-09-04', true)
      expect_candidate_event(@c3, '2016-07-23', false)
    end
    it 'should update only c1\'s & c3\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          completed_date: '2016-09-04',
          verified: false,
          candidate: {candidate_ids: [@c1.id, @c3.id]}

      expect_candidate_event(@c1, '2016-09-04', false)
      expect_candidate_event(@c2, '', false)
      expect_candidate_event(@c3, '2016-09-04', false)
    end

    def expect_candidate_event(candidate, completed_date, verified)
      c2 = Candidate.find_by_account_name(candidate.account_name)
      candidate_event = c2.get_candidate_event(@confirmation_event.name)
      expect(candidate_event.completed_date.to_s).to eq(completed_date)
      expect(candidate_event.verified).to eq(verified)
    end

  end

  describe 'set_candidates' do
    before(:each) do
      @admdin = login_admin
      @confirmation_event = AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))
    end
    it 'is sorted zero candidates' do
      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          sort: 'account_name',
          direction: 'desc',
          candidate: {candidate_ids: []}
      expect(controller.candidates.size).to eq(0)
    end
    it 'is sorted one candidate' do
      c1 = create_candidate('c1')

      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          sort: 'account_name',
          direction: 'desc',
          candidate: {candidate_ids: []}

      expect(controller.candidates.size).to eq(1)
      expect(controller.candidates.first).to eq(c1)
    end
    it 'is sorted two candidates' do
      c1 = create_candidate('c1')
      c2 = create_candidate('c2')

      put :mass_edit_candidates_event_update,
          id: @confirmation_event.id,
          sort: 'account_name',
          direction: 'desc',
          candidate: {candidate_ids: []}

      # order not important js will do it
      expect(controller.candidates.size).to eq(2)
      expect(controller.candidates.include? c2).to eq(true)
      expect(controller.candidates.include? c1).to eq(true)
    end
    describe 'three candidates' do

      before(:each) do
        @c1 = create_candidate('c1')
        @c2 = create_candidate('c2')
        @c3 = create_candidate('c3')
      end

      it 'is sorted by account name' do
        expect_column_sorting('account_name', @c1, @c2, @c3)
      end
      it 'is sorted by first name' do
        expect_column_sorting('candidate_sheet.first_name', @c3, @c1, @c2)
      end
      it 'is sorted by last name' do
        expect_column_sorting('candidate_sheet.last_name', @c2, @c3, @c1)
      end
      it 'is sorted by completed date' do
        expect_column_sorting('completed_date', @c1, @c3, @c2)
      end
    end
  end

  describe 'mass monthly mailing' do

    before(:each) do
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
    end
    it 'should set @candidates' do

      controller.monthly_mass_mailing

      expect(controller.candidates.size).to eq(3)
      expect(controller.candidates[0]).to eq(@c1)
      expect(controller.candidates[1]).to eq(@c2)
      expect(controller.candidates[2]).to eq(@c3)
    end
  end

  describe 'mass monthly mailing update' do

    before(:each) do
      @admin = login_admin
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
    end
    it 'should set @candidates' do

      expect(SendEmailJob).to receive(:perform_in).with(0, @c1, instance_of(CandidatesMailerText), @admin, false).exactly(:once) do |index, candidate, candidates_mailer_text, admin, isText|
        puts "index: #{index}"
        expect(index).to eq(0)
        expect_mailer_text(@c1, candidates_mailer_text)
        expect(admin).to eq(@admin)
        expect(isText).to eq(false)
      end
      expect(SendEmailJob).to receive(:perform_in).with(2, @c2, instance_of(CandidatesMailerText), @admin, false).exactly(:once) do |index, candidate, candidates_mailer_text, admin, isText|
        expect(index).to eq(2)
        expect_mailer_text(@c2, candidates_mailer_text)
        expect(admin).to eq(@admin)
        expect(isText).to eq(false)
      end
      request.env['HTTP_REFERER'] = monthly_mass_mailing_path

      put :monthly_mass_mailing_update,
          mail: {subject: 'www1',
                 pre_late_input: 'xxx',
                 pre_coming_due_input: 'yyy',
                 completed_input: 'zzz',
                 closing_text: 'ccc',
                 salutation_text: 'aaa',
                 from_text: 'bbb'},
          candidate: {candidate_ids: [@c1.id, @c2.id]},
          commit: I18n.t('email.monthly_mail')

      expect_message(:notice, I18n.t('messages.monthly_mailing_progress'))
      expect(render_template('edit_multiple_confirmation_events'))
      expect(response.status).to eq(200)

    end
  end

  describe 'mass edit candidates update' do

    before(:each) do
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')

      request.env['HTTP_REFERER'] = monthly_mass_mailing_path
    end

    describe 'do not login' do

      it 'delete fails if not logged in.' do

        put :mass_edit_candidates_update,
            commit: AdminsController::DELETE

        expect_message(:alert, I18n.t('devise.failure.unauthenticated'))
        expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'email fails if not logged in.' do

        put :mass_edit_candidates_update,
            commit: AdminsController::EMAIL

        expect_message(:alert, I18n.t('devise.failure.unauthenticated'))
        expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'reset-password fails if not logged in.' do

        put :mass_edit_candidates_update,
            commit: AdminsController::RESET_PASSWORD

        expect_message(:alert, I18n.t('devise.failure.unauthenticated'))
        expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'initial-email fails if not logged in.' do

        put :mass_edit_candidates_update,
            commit: AdminsController::INITIAL_EMAIL

        expect_message(:alert, I18n.t('devise.failure.unauthenticated'))
        expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end
    end

    describe 'admin login' do
      before(:each) do
        @admin = login_admin
      end

      describe 'No candidate selected' do

        it 'delete should return no_candidate_selected if none selected' do

          put :mass_edit_candidates_update,
              commit: AdminsController::DELETE

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'email should return no_candidate_selected if none selected' do

          put :mass_edit_candidates_update,
              commit: AdminsController::EMAIL

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'reset-password should return no_candidate_selected if none selected' do

          put :mass_edit_candidates_update,
              commit: AdminsController::RESET_PASSWORD

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'initial-email should return no_candidate_selected if none selected' do

          put :mass_edit_candidates_update,
              commit: AdminsController::INITIAL_EMAIL

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end
      end

      describe 'delete' do
        it 'should delete candidate if selected' do

          put :mass_edit_candidates_update,
              candidate: {candidate_ids: [@c2.id]},
              commit: AdminsController::DELETE

          expect_message(:notice, I18n.t('messages.candidates_deleted'))
          candidates = Candidate.all
          expect(candidates.size).to eq(2)
          expect(candidates.include?(@c2)).to eq(false)

        end
      end
      describe 'email' do
        it 'should render monthly mass mailing when email' do

          put :mass_edit_candidates_update,
              candidate: {candidate_ids: [@c2.id]},
              commit: AdminsController::EMAIL

          expect(render_template('monthly_mass_mailing'))

        end
      end
      describe 'reset password' do
        it 'should send reset password email when ' do

          expect(SendResetEmailJob).to receive(:perform_in).with(0, @c1, AdminsController::RESET_PASSWORD).exactly(:once)
          expect(SendResetEmailJob).to receive(:perform_in).with(2, @c2, AdminsController::RESET_PASSWORD).exactly(:once)

          put :mass_edit_candidates_update,
              candidate: {candidate_ids: [@c1.id, @c2.id]},
              commit: AdminsController::RESET_PASSWORD

          expect_message(:notice, I18n.t('messages.reset_password_message_sent'))
        end
      end
      describe 'initial email' do
        it 'should send initial email with reset password when ' do

          expect(SendResetEmailJob).to receive(:perform_in).with(0, @c2, AdminsController::INITIAL_EMAIL).exactly(:once)
          expect(SendResetEmailJob).to receive(:perform_in).with(2, @c3, AdminsController::INITIAL_EMAIL).exactly(:once)

          put :mass_edit_candidates_update,
              candidate: {candidate_ids: [@c2.id, @c3.id]},
              commit: AdminsController::INITIAL_EMAIL

          expect_message(:notice, I18n.t('messages.initial_email_sent'))
        end
      end
    end
  end

def expect_mailer_text(candidate, candidates_mailer_text)
  expect(candidates_mailer_text.candidate.id).to eq(candidate.id)
  expect(candidates_mailer_text.subject).to eq('www1')
  expect(candidates_mailer_text.pre_late_text).to eq('xxx')
  expect(candidates_mailer_text.pre_coming_due_text).to eq('yyy')
  expect(candidates_mailer_text.completed_text).to eq('zzz')
  expect(candidates_mailer_text.closing_text).to eq('ccc')
  expect(candidates_mailer_text.salutation_text).to eq('aaa')
  expect(candidates_mailer_text.from_text).to eq('bbb')
end


def expect_message(id, message)
  [:alert, :notice].each do |my_id|
    unless my_id == id
      expect(flash[my_id]).to eq(nil)
    end
  end
  expect(flash[id]).to eq(message) unless id.nil?
end

def expect_column_sorting(column, *candidates)

  put :mass_edit_candidates_event,
      id: @confirmation_event.id,
      sort: column,
      direction: 'asc',
      candidate: {candidate_ids: []}

  expect_message(nil, nil)
  # order not important js will do it
  expect(controller.candidates.size).to eq(candidates.size)
  candidates.each do |candidate|
    expect(controller.candidates.include? candidate).to eq(true)
  end

  put :mass_edit_candidates_event,
      id: @confirmation_event.id,
      sort: column,
      direction: 'desc',
      candidate: {candidate_ids: []}

  expect_message(nil, nil)
  # order not important js will do it
  expect(controller.candidates.size).to eq(candidates.size)
  candidates.each do |candidate|
    expect(controller.candidates.include? candidate).to eq(true)
  end
end

def create_candidate(prefix)
  candidate = FactoryGirl.create(:candidate, account_name: prefix)
  candidate_event = candidate.add_candidate_event(@confirmation_event)
  case prefix
    when 'c1'
      candidate.candidate_sheet.first_name = 'c2first_name'
      candidate.candidate_sheet.middle_name = 'c1middle_name'
      candidate.candidate_sheet.last_name = 'c3last_name'
      candidate_event.completed_date='2016-06-09'
    when 'c2'
      candidate.candidate_sheet.first_name = 'c3first_name'
      candidate.candidate_sheet.middle_name = 'c2middle_name'
      candidate.candidate_sheet.last_name = 'c1last_name'
      candidate_event.completed_date=''
    when 'c3'
      candidate.candidate_sheet.first_name = 'c1first_name'
      candidate.candidate_sheet.middle_name = 'c3middle_name'
      candidate.candidate_sheet.last_name = 'c2last_name'
      candidate_event.completed_date='2016-07-23'
    else
      throw RuntimeError.new('Unknown prefix')
  end
  candidate.save
  candidate
end

end