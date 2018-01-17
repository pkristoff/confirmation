Rails.application.routes.draw do

  get 'export_lists/retreat'
  get 'export_lists/baptism'
  get 'export_lists/sponsor'
  get 'export_lists/events'

  resources :candidate_imports

  post 'candidate_imports/check_events'
  post 'candidate_imports/reset_database'
  post 'candidate_imports/start_new_year'
  post 'candidate_imports/export_to_excel'
  post 'candidate_imports/orphaned_table_rows'

  devise_for :admins,
             controllers: {registrations: 'registrations',
                           confirmations: 'confirmations'
                           }

  resources :admins

  # Sign in CANDIDATE
  devise_for :candidates, :path_prefix => 'dev',
             controllers: {registrations: 'dev/registrations',
                           confirmations: 'dev/confirmations',
                           passwords: 'dev/passwords'
             }
  devise_scope :candidates do
    get 'show/:id', to: 'dev/candidates#show', as: 'dev_candidate'
    get 'event/:id', to: 'candidates#event', as: 'event_candidate'
    put 'event/:id', to: 'candidates#update', as: 'update_candidate'
    post 'update/:id', to: 'dev/registrations#update', as: 'update_candidate_registration'
    get 'dev/registrations/event/:id', to: 'dev/registrations#event', as: 'event_candidate_registration'
    post 'create', to: 'registrations#create', as: 'create_candidate'

    # common

    put 'dev/download_document/:id/.:name', to: 'dev/candidates#download_document', as: 'dev_download_document'
    put 'download_document/:id/.:name', to: 'candidates#download_document', as: 'download_document'

    # put 'mass_edit_candidates_event_sort/:id/:sort/:direction', to: 'admins#mass_edit_candidates_event_sort', as: 'mass_edit_candidates_event_sort'
    get 'mass_edit_candidates_event/:id', to: 'admins#mass_edit_candidates_event', as: 'mass_edit_candidates_event'
    put 'mass_edit_candidates_event_update/:id', to: 'admins#mass_edit_candidates_event_update', as: 'mass_edit_candidates_event_update'

    post 'mass_edit_candidates_update', to: 'admins#mass_edit_candidates_update', as: 'mass_edit_candidates_update'

    # email list of candidates there current status
    get 'monthly_mass_mailing', to: 'admins#monthly_mass_mailing', as: 'monthly_mass_mailing'
    put 'monthly_mass_mailing_update', to: 'admins#monthly_mass_mailing_update', as: 'monthly_mass_mailing_update'

    # adhoc email to a list of candidates
    get 'adhoc_mailing', to: 'admins#adhoc_mailing', as: 'adhoc_mailing'
    put 'adhoc_mailing_update', to: 'admins#adhoc_mailing_update', as: 'adhoc_mailing_update'

    # sign agreement

    get 'dev/sign_agreement.:id', to: 'dev/candidates#sign_agreement', as: 'dev_sign_agreement'
    put 'dev/sign_agreement.:id', to: 'dev/candidates#sign_agreement_update', as: 'dev_sign_agreement_update'

    get 'sign_agreement.:id', to: 'candidates#sign_agreement', as: 'sign_agreement'
    put 'sign_agreement.:id', to: 'candidates#sign_agreement_update', as: 'sign_agreement_update'

    # sponsor agreement

    get 'dev/sponsor_agreement.:id', to: 'dev/candidates#sponsor_agreement', as: 'dev_sponsor_agreement'
    put 'dev/sponsor_agreement.:id', to: 'dev/candidates#sponsor_agreement_update', as: 'dev_sponsor_agreement_update'

    get 'sponsor_agreement.:id', to: 'candidates#sponsor_agreement', as: 'sponsor_agreement'
    put 'sponsor_agreement.:id', to: 'candidates#sponsor_agreement_update', as: 'sponsor_agreement_update'

    # Christian Ministry Awareness

    get 'dev/christian_ministry.:id', to: 'dev/candidates#christian_ministry', as: 'dev_christian_ministry'
    put 'dev/christian_ministry.:id', to: 'dev/candidates#christian_ministry_update', as: 'dev_christian_ministry_update'

    get 'christian_ministry.:id', to: 'candidates#christian_ministry', as: 'christian_ministry'
    put 'christian_ministry.:id', to: 'candidates#christian_ministry_update', as: 'christian_ministry_update'

    get 'christian_ministry_verify.:id', to: 'candidates#christian_ministry_verify', as: 'christian_ministry_verify'
    put 'christian_ministry_verify.:id', to: 'candidates#christian_ministry_verify_update', as: 'christian_ministry_verify_update'

    # candidate sheet

    get 'dev/candidate_sheet.:id', to: 'dev/candidates#candidate_sheet', as: 'dev_candidate_sheet'
    put 'dev/candidate_sheet.:id', to: 'dev/candidates#candidate_sheet_update', as: 'dev_candidate_sheet_update'

    get 'candidate_sheet.:id', to: 'candidates#candidate_sheet', as: 'candidate_sheet'
    put 'candidate_sheet.:id', to: 'candidates#candidate_sheet_update', as: 'candidate_sheet_update'

    # Baptismal Certificate

    # Sponsor covenant
    get 'dev/upload_sponsor_eligibility_image.:id', to: 'dev/candidates#upload_sponsor_eligibility_image', as: 'dev_upload_sponsor_eligibility_image'
    get 'upload_sponsor_eligibility_image.:id', to: 'candidates#upload_sponsor_eligibility_image', as: 'upload_sponsor_eligibility_image'

    # Pick confirmation name

    get 'dev/pick_confirmation_name.:id', to: 'dev/candidates#pick_confirmation_name', as: 'dev_pick_confirmation_name'
    put 'dev/pick_confirmation_name.:id', to: 'dev/candidates#pick_confirmation_name_update', as: 'dev_pick_confirmation_name_update'

    get 'pick_confirmation_name.:id', to: 'candidates#pick_confirmation_name', as: 'pick_confirmation_name'
    put 'pick_confirmation_name.:id', to: 'candidates#pick_confirmation_name_update', as: 'pick_confirmation_name_update'

    get 'pick_confirmation_name_verify.:id', to: 'candidates#pick_confirmation_name_verify', as: 'pick_confirmation_name_verify'
    put 'pick_confirmation_name_verify.:id', to: 'candidates#pick_confirmation_name_verify_update', as: 'pick_confirmation_name_verify_update'

    # event_with_picture

    get 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture', as: 'dev_event_with_picture'
    put 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture_update', as: 'dev_event_with_picture_update'

    get 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture', as: 'event_with_picture'
    put 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture_update', as: 'event_with_picture_update'

    get 'dev/show_event_with_picture.:id', to: 'dev/candidates#show_event_with_picture', as: 'dev_show_event_with_picture'
    get 'dev/event_with_picture_image/:id/:event_name', to: 'dev/candidates#event_with_picture_image', as: 'dev_event_with_picture_image'

    get 'show_event_with_picture.:id', to: 'candidates#show_event_with_picture', as: 'show_event_with_picture'
    get 'event_with_picture_image/:id/:event_name', to: 'candidates#event_with_picture_image', as: 'event_with_picture_image'

    # admin confirmation_events

    get 'edit_multiple_confirmation_events/', to: 'admins#edit_multiple_confirmation_events', as: 'edit_multiple_confirmation_events'
    post 'update_multiple_confirmation_events/', to: 'admins#update_multiple_confirmation_events', as: 'update_multiple_confirmation_events'

  end

  # candidate confirmation
  get 'my_candidate_confirmation/:id/:errors', to: 'visitors#candidate_confirmation', as: 'my_candidate_confirmation'

  # Sign in ADMIN
  resources :candidates
  root to: 'visitors#index'
  get 'contact_information', to: 'visitors#contact_information'
  get 'about', to: 'visitors#about'
end
