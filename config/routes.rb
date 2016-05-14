Rails.application.routes.draw do
  devise_for :admins,
             controllers: {:registrations => "registrations"}
  resources :admins
  # namespace :dev do
  #   devise_for :candidates
  # end
  devise_for :candidates, :path_prefix => 'dev',
             controllers: {:registrations => "registrations"}
  resources :candidates
  # namespace :dev do
  #   devise_for :candidates
  #   resources :candidates
  # end
  root to: 'visitors#index'
end
