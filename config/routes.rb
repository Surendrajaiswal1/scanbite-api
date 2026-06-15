Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        resource :session, only: :create

        resource :registration, only: :create

        resources :otp_verifications, only: :create do
          collection do
            post :resend
          end
        end

        resource :password, only: [] do
          collection do
            post :forgot
            post :reset
          end
        end

        resource :google_auth, only: :create
      end

      resource :user, only: [:show, :update]

      resource :business_profile, only: [:show, :create, :update] do
        post :complete_onboarding, on: :collection
      end

      resources :menu_items, only: [:index, :create, :update, :destroy] do
        collection do
          post :import_csv
        end
      end

      resources :orders, only: [:index, :update]

      get 'public_menus/:slug', to: 'public_menus#show'
      post 'public_menus/:slug/orders', to: 'public_menus#create_order'
    end
  end
end