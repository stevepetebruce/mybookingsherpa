Rails.application.routes.draw do
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Sidekiq routes
  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Devise routes
  devise_for :guests
  devise_for :guides, controllers: {
    registrations: "guides/registrations"
  }

  devise_scope :guide do
    authenticated :guide do
      root "guides/trips#index", as: :authenticated_guide
    end

    unauthenticated do
      root "devise/sessions#new", as: :unauthenticated_guide
    end
  end

  devise_scope :guest do
    authenticated :guest do
      root "guests/trips#index", as: :authenticated_guest
    end

    unauthenticated do
      root "devise/sessions#new", as: :unauthenticated_guest
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Plain old routes
  resources :guests, only: %i[edit show update]

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Nested resources
  namespace :guides, only: %i[] do # Devise handles all guest actions
    resources :bookings, only: %i[show]
    resources :trips, only: %i[create index edit new update]
    resources :trips, only: %i[] do
      resources :bookings, only: %i[index], controller: "/guides/trips/bookings"
    end
    namespace :welcome, only: %i[new] do
      resources :solos, only: %i[new create update]
      resources :companies, only: %i[new create update]
    end
  end

  get "guides/welcome", to: "guides/welcome#new"

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
