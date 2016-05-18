Rails.application.routes.draw do
  get 'candidate_imports_controller/new'

  get 'candidate_imports_controller/create'

  devise_for :admins,
             controllers: {:registrations => "registrations"}
  resources :admins

  # Sign in CANDIDATE
  devise_for :candidates, :path_prefix => 'dev',
             controllers: {:registrations => "dev/registrations"}
  devise_scope :candidates do
    # get :index, to: "dev/candidates#index", as: "dev_candidates"
    get 'show/:id', to: "dev/candidates#show", as: "dev_candidate"
    post 'update/:id', to: "dev/registrations#update", as: "update_candidate_registration"
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
