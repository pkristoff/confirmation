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

    get 'dev/upload_baptismal_certificate.:id', to: 'dev/candidates#upload_baptismal_certificate', as: 'dev_upload_baptismal_certificate'
    put 'dev/upload_baptismal_certificate.:id', to: 'dev/candidates#baptismal_certificate_update', as: 'dev_baptismal_certificate_update'

    get 'dev/show_baptism_certificate.:id', to: 'dev/candidates#show_baptism_certificate', as: 'dev_show_baptism_certificate'
    get 'dev/upload_baptismal_certificate_image.:id', to: 'dev/candidates#upload_baptismal_certificate_image', as: 'dev_upload_baptismal_certificate_image'

    get 'upload_baptismal_certificate.:id', to: 'candidates#upload_baptismal_certificate', as: 'upload_baptismal_certificate'
    put 'upload_baptismal_certificate.:id', to: 'candidates#baptismal_certificate_update', as: 'baptismal_certificate_update'

    get 'show_baptism_certificate.:id', to: 'candidates#show_baptism_certificate', as: 'show_baptism_certificate'
    get 'upload_baptismal_certificate_image.:id', to: 'candidates#upload_baptismal_certificate_image', as: 'upload_baptismal_certificate_image'

    # Confirmation name

    get 'dev/confirmation_name.:id', to: 'dev/candidates#confirmation_name', as: 'dev_confirmation_name'
    put 'dev/confirmation_name.:id', to: 'dev/candidates#confirmation_name_update', as: 'dev_confirmation_name_update'

    get 'confirmation_name.:id', to: 'candidates#confirmation_name', as: 'confirmation_name'
    put 'confirmation_name.:id', to: 'candidates#confirmation_name_update', as: 'confirmation_name_update'

    # Sponsor covenant

    get 'dev/upload_sponsor_covenant.:id', to: 'dev/candidates#upload_sponsor_covenant', as: 'dev_upload_sponsor_covenant'
    put 'dev/upload_sponsor_covenant.:id', to: 'dev/candidates#sponsor_covenant_update', as: 'dev_sponsor_covenant_update'

    get 'dev/show_sponsor_elegibility.:id', to: 'dev/candidates#show_sponsor_elegibility', as: 'dev_show_sponsor_elegibility'
    get 'dev/upload_sponsor_elegibility_image.:id', to: 'dev/candidates#upload_sponsor_elegibility_image', as: 'dev_upload_sponsor_elegibility_image'

    get 'upload_sponsor_covenant.:id', to: 'candidates#upload_sponsor_covenant', as: 'upload_sponsor_covenant'
    put 'upload_sponsor_covenant.:id', to: 'candidates#sponsor_covenant_update', as: 'sponsor_covenant_update'

    get 'show_sponsor_elegibility.:id', to: 'candidates#show_sponsor_elegibility', as: 'show_sponsor_elegibility'
    get 'upload_sponsor_elegibility_image.:id', to: 'candidates#upload_sponsor_elegibility_image', as: 'upload_sponsor_elegibility_image'

  end

  # Sign in ADMIN
  resources :candidates
  # namespace :dev do
  #   devise_for :candidates
  #   resources :candidates
  # end
  root to: 'visitors#index'
end
