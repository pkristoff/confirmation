Rails.application.routes.draw do

  resources :candidate_imports

  post 'candidate_imports/reset_database'
  post 'candidate_imports/remove_all_candidates'
  post 'candidate_imports/export_to_excel'

  devise_for :admins,
             controllers: {:registrations => "registrations"}
  resources :admins

  # Sign in CANDIDATE
  devise_for :candidates, :path_prefix => 'dev',
             controllers: {:registrations => "dev/registrations"}
  devise_scope :candidates do
    get 'show/:id', to: "dev/candidates#show", as: "dev_candidate"
    get 'event/:id', to: "candidates#event", as: "event_candidate"
    put 'event/:id', to: "candidates#update", as: "update_candidate"
    delete 'event/:id', to: "candidates#destroy", as: "destroy_candidate"
    post 'update/:id', to: "dev/registrations#update", as: "update_candidate_registration"
    get 'dev/registrations/event/:id', to: "dev/registrations#event", as: "event_candidate_registration"
    post 'create', to: "registrations#create", as: 'create_candidate'
  end

  # Sign in ADMIN
  resources :candidates
  # namespace :dev do
  #   devise_for :candidates
  #   resources :candidates
  # end
  root to: 'visitors#index'
end
