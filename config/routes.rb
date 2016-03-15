Rails.application.routes.draw do
  devise_for :admins,
             controllers: {:registrations => "registrations"}
  resources :admins
  devise_for :users
  resources :users
  root to: 'visitors#index'
end
