Rails.application.routes.draw do
  devise_for :admins,
             controllers: {:registrations => "registrations"}
  resources :admins
  devise_for :candidates
  resources :candidates
  root to: 'visitors#index'
end
