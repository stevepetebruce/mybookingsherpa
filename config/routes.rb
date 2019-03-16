Rails.application.routes.draw do
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Devise routes
  devise_for :guests
  devise_for :guides

  devise_scope :guest do
    authenticated :guest do
      root 'home#index', as: :authenticated_guest
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_guest
    end
  end

  devise_scope :guide do
    authenticated :guide do
      root 'home#index', as: :authenticated_guide
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_guide
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Plain old routes
  resources :guests, only: %i[edit show update]

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Nested resources
  namespace :guides, only: %i[] do # Devise handles all guest actions
    resources :guests, only: %i[show]
    resources :trips, only: %i[create edit index new show update]
  end

  namespace :guests, only: %i[] do # Devise handles all guest actions
    resources :trips, only: %i[show index]
  end

  namespace :public do
    resources :trips, only: %i[] do
      resources :bookings, only: %i[create edit new show update],
                           shallow: true, controller: "/public/trips/bookings"
    end
  end
end
