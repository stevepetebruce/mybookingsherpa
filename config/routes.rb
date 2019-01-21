Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "trips#index"

  devise_for :guests
  devise_for :guides

  resources :trips
  resources :guests, only: %i[edit index new show update]

  namespace :public do
    resources :trips, only: %i[] do
      resources :bookings, only: %i[create edit new show update],
                           shallow: true, controller: "/public/trips/bookings"
    end
  end
end
