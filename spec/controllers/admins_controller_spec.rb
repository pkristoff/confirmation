# frozen_string_literal: true

describe AdminsController do
  before do
    FactoryBot.create(:visitor)
    @admin = login_admin
  end

  it 'NOT have a current_candidate' do
    expect(subject.current_candidate).to be_nil
  end

  describe 'authentication' do
    it 'fail authentication' do
      login_candidate
      get :index
      expect(@candidates).to be_nil
    end

    it 'pass authentication and set @admins' do
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
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.size).to eq(1)
    end

    it 'is sorted two event' do
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce1)
      expect(confirmation_events.size).to eq(2)
    end

    it 'is sorted three event' do
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      ce3 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-29', chs_due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce3)
      expect(confirmation_events.second).to eq(ce2)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end

    it 'is sorted three event: one nil' do
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce3 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-29', chs_due_date: '2016-05-22')
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end

    it 'is sorted three event: two nil' do
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-31', chs_due_date: '2016-05-24')
      ce2 = FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce3 = FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce2)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce1)
      expect(confirmation_events.size).to eq(3)
    end

    it 'is sorted three event: two nil 2' do
      ce1 = FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      ce2 = FactoryBot.create(:confirmation_event, the_way_due_date: '2016-05-30', chs_due_date: '2016-05-23')
      ce3 = FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil)
      controller.set_confirmation_events
      confirmation_events = controller.confirmation_events
      expect(confirmation_events.first).to eq(ce1)
      expect(confirmation_events.second).to eq(ce3)
      expect(confirmation_events.third).to eq(ce2)
      expect(confirmation_events.size).to eq(3)
    end
  end

  describe 'mass_edit_candidates_event_update' do
    before do
      @confirmation_event = AppFactory.add_confirmation_event(CandidateSheet.event_key)
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
    end

    it 'NOT update any candidate\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          params: { id: @confirmation_event.id,
                    completed_date: '2016-09-04',
                    verified: true,
                    candidate: { candidate_ids: [] } }
      expect_candidate_event(@c1, '2016-06-09', false)
      expect_candidate_event(@c2, '', false)
      expect_candidate_event(@c3, '2016-07-23', false)
    end

    it 'update only c2\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          params: { id: @confirmation_event.id,
                    completed_date: '2016-09-04',
                    verified: true,
                    candidate_ids: [@c2.id] }

      expect_candidate_event(@c1, '2016-06-09', false)
      expect_candidate_event(@c2, '2016-09-04', true)
      expect_candidate_event(@c3, '2016-07-23', false)
    end

    it 'update only c1\'s & c3\'s candidate_event' do
      put :mass_edit_candidates_event_update,
          params: { id: @confirmation_event.id,
                    completed_date: '2016-09-04',
                    verified: false,
                    candidate_ids: [@c1.id, @c3.id] }

      expect_candidate_event(@c1, '2016-09-04', false)
      expect_candidate_event(@c2, '', false)
      expect_candidate_event(@c3, '2016-09-04', false)
    end

    private

    def expect_candidate_event(candidate, completed_date, verified)
      c2 = Candidate.find_by(account_name: candidate.account_name)
      candidate_event = c2.get_candidate_event(@confirmation_event.event_key)
      expect(candidate_event.completed_date.to_s).to eq(completed_date)
      expect(candidate_event.verified).to eq(verified)
    end
  end

  describe 'mass monthly mailing' do
    before do
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
    end

    it 'set @candidates' do
      controller.monthly_mass_mailing

      expect(controller.candidate_info.size).to eq(3)
      expect(controller.candidate_info[0].id).to eq(@c1.id)
      expect(controller.candidate_info[1].id).to eq(@c2.id)
      expect(controller.candidate_info[2].id).to eq(@c3.id)
    end
  end

  describe 'mass monthly mailing update' do
    before do
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')
      AppFactory.add_confirmation_events
    end

    it 'set @candidates' do
      request.env['HTTP_REFERER'] = monthly_mass_mailing_path

      put :monthly_mass_mailing_update,
          params: { mail: { subject: 'www1',
                            pre_late_input: 'xxx',
                            pre_coming_due_input: 'yyy',
                            completed_input: 'zzz',
                            closing_input: 'ccc',
                            salutation_input: 'aaa',
                            from_input: 'bbb' },
                    candidate: { candidate_ids: [@c1.id, @c2.id] },
                    commit: I18n.t('email.monthly_mail') }

      expect_message(:notice, I18n.t('messages.monthly_mailing_progress'))
      # expect(render_template('edit_multiple_confirmation_events'))
      expect(response.status).to eq(200)
    end
  end

  describe 'mass edit candidates update' do
    before do
      @c1 = create_candidate('c1')
      @c2 = create_candidate('c2')
      @c3 = create_candidate('c3')

      request.env['HTTP_REFERER'] = monthly_mass_mailing_path
    end

    describe 'do not login' do
      it 'delete fails if not logged in.' do
        put :mass_edit_candidates_update,
            params: { commit: AdminsController::DELETE }

        expect_message(:alert, I18n.t('messages.no_candidate_selected'))
        # expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'email fails if not logged in.' do
        put :mass_edit_candidates_update,
            params: { commit: AdminsController::EMAIL }

        expect_message(:alert, I18n.t('messages.no_candidate_selected'))
        # expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'reset-password fails if not logged in.' do
        put :mass_edit_candidates_update,
            params: { commit: AdminsController::RESET_PASSWORD }

        expect_message(:alert, I18n.t('messages.no_candidate_selected'))
        # expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end

      it 'initial-email fails if not logged in.' do
        put :mass_edit_candidates_update,
            params: { commit: AdminsController::INITIAL_EMAIL }

        expect_message(:alert, I18n.t('messages.no_candidate_selected'))
        # expect(render_template('edit_multiple_confirmation_events'))
        expect(response.status).to eq(302)
      end
    end

    describe 'admin login' do
      describe 'No candidate selected' do
        it 'delete return no_candidate_selected if none selected' do
          put :mass_edit_candidates_update,
              params: { commit: AdminsController::DELETE }

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          # expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'email return no_candidate_selected if none selected' do
          put :mass_edit_candidates_update,
              params: { commit: AdminsController::EMAIL }

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          # expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'reset-password return no_candidate_selected if none selected' do
          put :mass_edit_candidates_update,
              params: { commit: AdminsController::RESET_PASSWORD }

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          # expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end

        it 'initial-email return no_candidate_selected if none selected' do
          put :mass_edit_candidates_update,
              params: { commit: AdminsController::INITIAL_EMAIL }

          expect_message(:alert, I18n.t('messages.no_candidate_selected'))
          # expect(render_template('edit_multiple_confirmation_events'))
          expect(response.status).to eq(302)
        end
      end

      describe 'delete' do
        it 'delete candidate if selected' do
          put :mass_edit_candidates_update,
              params: { candidate: { candidate_ids: [@c2.id] },
                        button: AdminsController::DELETE }

          expect_message(:notice, I18n.t('messages.candidates_deleted'))
          candidates = Candidate.all
          expect(candidates.size).to eq(2)
          expect(candidates.include?(@c2)).to be(false)
        end
      end

      describe 'reset password' do
        it 'send reset password email when ...' do
          put :mass_edit_candidates_update,
              params: { candidate: { candidate_ids: [@c1.id, @c2.id] },
                        button: AdminsController::RESET_PASSWORD }

          expect_message(:notice, I18n.t('messages.reset_password_message_sent'))
        end
      end

      describe 'initial email' do
        it 'send initial email with reset password when ...' do
          put :mass_edit_candidates_update,
              params: { candidate: { candidate_ids: [@c2.id, @c3.id] },
                        button: AdminsController::INITIAL_EMAIL }

          expect_message(:notice, I18n.t('messages.confirmation_email_sent'))
        end
      end
    end
  end

  describe 'confirm account' do
    before do
      @c1 = create_candidate('c1', should_confirm: false)
      @c2 = create_candidate('c2', should_confirm: false)
      @c3 = create_candidate('c3', should_confirm: false)
    end

    it 'confirm all accounts' do
      ids = [@c1.id, @c2.id, @c3.id]
      request.env['HTTP_REFERER'] = mass_edit_candidates_update_path

      put :mass_edit_candidates_update,
          params: { button: AdminsController::CONFIRM_ACCOUNT,
                    candidate: { candidate_ids: ids } }

      expect_message(:notice, I18n.t('messages.account_confirmed', number_confirmed: ids.size, number_not_confirmed: 0))
      ids.each do |id|
        expect(Candidate.find(id).account_confirmed?).to be(true)
      end
    end

    it 'confirm all accounts sent' do
      ids = [@c1.id, @c3.id]
      request.env['HTTP_REFERER'] = mass_edit_candidates_update_path

      put :mass_edit_candidates_update,
          params: { button: AdminsController::CONFIRM_ACCOUNT,
                    candidate: { candidate_ids: ids } }

      expect_message(:notice, I18n.t('messages.account_confirmed', number_confirmed: ids.size, number_not_confirmed: 0))
      ids.each do |id|
        expect(Candidate.find(id).account_confirmed?).to be(true)
      end
      expect(Candidate.find(@c2.id).account_confirmed?).to be(false)
    end

    it 'confirm all accounts sent except confirmed ones' do
      c2 = Candidate.find(@c2.id)
      c2.confirm_account
      c2.save

      ids = [@c1.id, @c2.id, @c3.id]
      request.env['HTTP_REFERER'] = mass_edit_candidates_update_path

      put :mass_edit_candidates_update,
          params: { button: AdminsController::CONFIRM_ACCOUNT,
                    candidate: { candidate_ids: ids } }

      expect_message(:notice, I18n.t('messages.account_confirmed', number_confirmed: ids.size - 1, number_not_confirmed: 1))
      ids.each do |id|
        expect(Candidate.find(id).account_confirmed?).to be(true)
      end
    end
  end

  private

  def expect_mailer_text(candidate, candidates_mailer_text)
    expect(candidates_mailer_text.candidate.id).to eq(candidate.id)
    expect(candidates_mailer_text.subject).to eq('www1')
    expect(candidates_mailer_text.pre_late_input).to eq('xxx')
    expect(candidates_mailer_text.pre_coming_due_input).to eq('yyy')
    expect(candidates_mailer_text.completed_input).to eq('zzz')
    expect(candidates_mailer_text.closing_input).to eq('ccc')
    expect(candidates_mailer_text.salutation_input).to eq('aaa')
    expect(candidates_mailer_text.from_input).to eq('bbb')
  end

  def expect_message(id, message)
    %i[alert notice].each do |my_id|
      expect(flash[my_id]).to be_nil unless my_id == id
    end
    expect(flash[id]).to eq(message) unless id.nil?
  end

  def expect_column_sorting(column, *candidates)
    put :mass_edit_candidates_event,
        params: { id: @confirmation_event.id,
                  sort: column,
                  direction: 'asc',
                  # with upgrade to 5.0 params will remove
                  # candidate from params if candidate_ids is empty
                  # so we force it to have something.  This is a test only
                  # hack - productions does not seem to be a problem.
                  candidate: { candidate_ids: [-1] } }

    expect_message(nil, nil)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(candidates.size)
    candidates.each_with_index do |candidate, index|
      expect(controller.candidate_info[index].id).to eq(candidate.id)
    end

    put :mass_edit_candidates_event,
        params: { id: @confirmation_event.id,
                  sort: column,
                  direction: 'desc',
                  # with upgrade to 5.0 params will remove
                  # candidate from params if candidate_ids is empty
                  # so we force it to have something.  This is a test only
                  # hack - productions does not seem to be a problem.
                  candidate: { candidate_ids: [-1] } }

    expect_message(nil, nil)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(candidates.size)
    candidates.each_index do |candidate, index|
      expect(controller.candidate_info[index].id).to eq(candidate.id)
    end
  end

  def create_candidate(prefix, should_confirm: true)
    AppFactory.generate_default_status if Status.count == 0
    candidate = FactoryBot.create(:candidate, account_name: prefix, should_confirm: should_confirm)
    candidate_event = candidate.add_candidate_event(@confirmation_event)
    case prefix
    when 'c1'
      candidate.candidate_sheet.first_name = 'c2first_name'
      candidate.candidate_sheet.middle_name = 'c1middle_name'
      candidate.candidate_sheet.last_name = 'c3last_name'
      candidate.candidate_sheet.candidate_email = 'c3last_name.c3first_name@test.com'
      candidate_event.completed_date = '2016-06-09'
    when 'c2'
      candidate.candidate_sheet.first_name = 'c3first_name'
      candidate.candidate_sheet.middle_name = 'c2middle_name'
      candidate.candidate_sheet.last_name = 'c1last_name'
      candidate.candidate_sheet.candidate_email = 'c1last_name.c3first_name@test.com'
      candidate_event.completed_date = ''
    when 'c3'
      candidate.candidate_sheet.first_name = 'c1first_name'
      candidate.candidate_sheet.middle_name = 'c3middle_name'
      candidate.candidate_sheet.last_name = 'c2last_name'
      candidate.candidate_sheet.candidate_email = 'c2last_name.c1first_name@test.com'
      candidate_event.completed_date = '2016-07-23'
    else
      throw RuntimeError.new('Unknown prefix')
    end
    candidate.save
    candidate
  end

  describe 'destroy admin' do
    it 'not destroy the only admin' do
      # admin = FactoryBot.create(:admin)
      sign_in(@admin)
      params = { commit: :destroy, controller: :admins, action: :destroy, id: @admin.id.to_s }
      delete :destroy, params: params
      expect_message(:alert, I18n.t('messages.flash.alert.admin.delete'))
    end

    it 'not destroy the only logged in admin' do
      admin2 = FactoryBot.create(:admin, account_name: 'Admin1', name: 'foo', email: 'paul@kristoffs.com')
      sign_in(admin2)
      params = { commit: :destroy, controller: :admins, action: :destroy, id: admin2.id.to_s }
      delete :destroy, params: params
      expect_message(:alert, I18n.t('messages.flash.alert.admin.delete'))
    end
    # write more tests that delete admins
  end
end
