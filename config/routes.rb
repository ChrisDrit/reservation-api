require "sidekiq/web"

Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :reservations, only: [:create]
    end
  end

  # Sidekiq
  #
  # Configure Sidekiq specific session middleware.
  #
  # Normally we'd want to auth this request, but skipping
  # for this simple, test application.
  #
  Sidekiq::Web.use ActionDispatch::Cookies
  Sidekiq::Web.use Rails.application.config.session_store, Rails.application.config.session_options
  ReservationApi::Application.routes.draw do
    mount Sidekiq::Web => "/sidekiq"
  end
end
