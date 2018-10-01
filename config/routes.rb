Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'trips#index'

  devise_for :guests
  devise_for :guides

  resources :trips
  resources :guests, only: %i(create edit index new show update)
end
