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

    # Sponsor covenant
    get 'dev/upload_sponsor_elegibility_image.:id', to: 'dev/candidates#upload_sponsor_elegibility_image', as: 'dev_upload_sponsor_elegibility_image'
    get 'upload_sponsor_elegibility_image.:id', to: 'candidates#upload_sponsor_elegibility_image', as: 'upload_sponsor_elegibility_image'

    # Pick confirmation name

    # event_with_picture

    get 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture', as: 'dev_event_with_picture'
    put 'dev/event_with_picture/:id/:event_name', to: 'dev/candidates#event_with_picture_update', as: 'dev_event_with_picture_update'

    get 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture', as: 'event_with_picture'
    put 'event_with_picture/:id/:event_name', to: 'candidates#event_with_picture_update', as: 'event_with_picture_update'

    get 'dev/show_event_with_picture.:id', to: 'dev/candidates#show_event_with_picture', as: 'dev_show_event_with_picture'
    get 'dev/event_with_picture_image/:id/:event_name', to: 'dev/candidates#event_with_picture_image', as: 'dev_event_with_picture_image'

    get 'show_event_with_picture.:id', to: 'candidates#show_event_with_picture', as: 'show_event_with_picture'
    get 'event_with_picture_image/:id/:event_name', to: 'candidates#event_with_picture_image', as: 'event_with_picture_image'

  end

  # Sign in ADMIN
  resources :candidates
  root to: 'visitors#index'
end
