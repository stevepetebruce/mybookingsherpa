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
  # devise_for :guests # can reinstate when we are sure and secure
  devise_for :guides, controllers: {
    registrations: "guides/registrations",
    sessions: "guides/sessions"
  }

  devise_scope :guide do
    authenticated :guide do
      root "guides/trips#new", welcome_to_my_booking_sherpa: :hello, as: :authenticated_guide
    end

    unauthenticated do
      root "devise/sessions#new", as: :unauthenticated_guide
      # For launch:
      get "/early_access_jan_2020", to: "guides/registrations#new"
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
    resources :trips, only: %i[create destroy edit index new update]
    resources :trips, only: %i[] do
      resources :bookings, only: %i[index], controller: "/guides/trips/bookings"
    end
    namespace :welcome, only: %i[new] do
      resources :bank_accounts, only: %i[new create]
    end
  end

  get "guides/welcome/stripe_account_link_failure",
    to: "guides/welcome/stripe_account_link_failure#new"

  namespace :guests, only: %i[] do # Devise handles all guest actions
    resources :trips, only: %i[show index]
  end

  namespace :public do
    resources :trips, only: %i[] do
      resources :bookings, only: %i[create edit new show update],
                           shallow: true,
                           controller: "/public/trips/bookings" do
        resources :failed_payments, only: %i[create new show],
                                    controller: "/public/trips/bookings/failed_payments",
                                    shallow: true
      end
    end
  end

  namespace :webhooks do
    namespace :stripe_api do
      resources :accounts, only: %i[create]
      resources :payment_intents, only: %i[create]
    end
  end
end
