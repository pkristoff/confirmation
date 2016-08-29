Rails.application.routes.draw do

  resources :candidate_imports

  post 'candidate_imports/reset_database'
  post 'candidate_imports/remove_all_candidates'
  post 'candidate_imports/export_to_excel'

  devise_for :admins,
             controllers: {:registrations => 'registrations'}
  devise_scope :admins do
    get '/events' => 'admins#events'
    put '/events.:id' => 'admins#events_update'
  end

  resources :admins

  # Sign in CANDIDATE
  devise_for :candidates, :path_prefix => 'dev',
             controllers: {:registrations => 'dev/registrations'}
  devise_scope :candidates do
    get 'show/:id', to: 'dev/candidates#show', as: 'dev_candidate'
    get 'event/:id', to: 'candidates#event', as: 'event_candidate'
    put 'event/:id', to: 'candidates#update', as: 'update_candidate'
    delete 'event/:id', to: 'candidates#destroy', as: 'destroy_candidate'
    post 'update/:id', to: 'dev/registrations#update', as: 'update_candidate_registration'
    get 'dev/registrations/event/:id', to: 'dev/registrations#event', as: 'event_candidate_registration'
    post 'create', to: 'registrations#create', as: 'create_candidate'

    # common

    put 'dev/download_document/:id/.:name', to: 'dev/candidates#download_document', as: 'dev_download_document'

    # sign agreement

    get 'dev/sign_agreement.:id', to: 'dev/candidates#sign_agreement', as: 'dev_sign_agreement'
    put 'dev/sign_agreement.:id', to: 'dev/candidates#sign_agreement_update', as: 'dev_sign_agreement_update'

    get 'sign_agreement.:id', to: 'candidates#sign_agreement', as: 'sign_agreement'
    put 'sign_agreement.:id', to: 'candidates#sign_agreement_update', as: 'sign_agreement_update'

    # candidate sheet

    get 'dev/candidate_sheet.:id', to: 'dev/candidates#candidate_sheet', as: 'dev_candidate_sheet'
    put 'dev/candidate_sheet.:id', to: 'dev/candidates#candidate_sheet_update', as: 'dev_candidate_sheet_update'

    get 'candidate_sheet.:id', to: 'candidates#candidate_sheet', as: 'candidate_sheet'
    put 'candidate_sheet.:id', to: 'candidates#candidate_sheet_update', as: 'candidate_sheet_update'

    # Baptismal Certificate

    get 'dev/show_baptism_certificate.:id', to: 'dev/candidates#show_baptism_certificate', as: 'dev_show_baptism_certificate'
    get 'dev/upload_baptismal_certificate_image.:id', to: 'dev/candidates#upload_baptismal_certificate_image', as: 'dev_upload_baptismal_certificate_image'

    get 'show_baptism_certificate.:id', to: 'candidates#show_baptism_certificate', as: 'show_baptism_certificate'
    get 'upload_baptismal_certificate_image.:id', to: 'candidates#upload_baptismal_certificate_image', as: 'upload_baptismal_certificate_image'

    # Sponsor covenant

    get 'dev/show_sponsor_covenant.:id', to: 'dev/candidates#show_sponsor_covenant', as: 'dev_show_sponsor_covenant'
    get 'dev/upload_sponsor_covenant_image.:id', to: 'dev/candidates#upload_sponsor_covenant_image', as: 'dev_upload_sponsor_covenant_image'

    get 'dev/show_sponsor_elegibility.:id', to: 'dev/candidates#show_sponsor_elegibility', as: 'dev_show_sponsor_elegibility'
    get 'dev/upload_sponsor_elegibility_image.:id', to: 'dev/candidates#upload_sponsor_elegibility_image', as: 'dev_upload_sponsor_elegibility_image'

    get 'show_sponsor_covenant.:id', to: 'candidates#show_sponsor_covenant', as: 'show_sponsor_covenant'
    get 'upload_sponsor_covenant_image.:id', to: 'candidates#upload_sponsor_covenant_image', as: 'upload_sponsor_covenant_image'

    get 'show_sponsor_elegibility.:id', to: 'candidates#show_sponsor_elegibility', as: 'show_sponsor_elegibility'
    get 'upload_sponsor_elegibility_image.:id', to: 'candidates#upload_sponsor_elegibility_image', as: 'upload_sponsor_elegibility_image'

    # Pick confirmation name

    get 'dev/show_pick_confirmation_name.:id', to: 'dev/candidates#show_pick_confirmation_name', as: 'dev_show_pick_confirmation_name'
    get 'dev/pick_confirmation_name_image.:id', to: 'dev/candidates#pick_confirmation_name_image', as: 'dev_pick_confirmation_name_image'

    get 'show_pick_confirmation_name.:id', to: 'candidates#show_pick_confirmation_name', as: 'show_pick_confirmation_name'
    get 'pick_confirmation_name_image.:id', to: 'candidates#pick_confirmation_name_image', as: 'pick_confirmation_name_image'

    # event_with_picture

    get 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture', as: 'dev_event_with_picture'
    put 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture_update', as: 'dev_event_with_picture_update'

    get 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture', as: 'event_with_picture'
    put 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture_update', as: 'event_with_picture_update'

  end

  # Sign in ADMIN
  resources :candidates
  # namespace :dev do
  #   devise_for :candidates
  #   resources :candidates
  # end
  root to: 'visitors#index'
end
