Rails.application.routes.draw do
  devise_for :admins
  resources :admins
  devise_for :users
  resources :users
  root to: 'visitors#index'
end
