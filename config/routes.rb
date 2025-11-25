Rails.application.routes.draw do
  get "health/show"
  ## 通常の Devise 認証 (HTMLフォーム + Cookie セッション) 用ルートを作る
  ## Devise が提供するルーティングヘルパーで、ユーザー認証に必要なルートとヘルパーを自動生成する
  ## 次がないと"authenticate_user!"が使えないので、トークン認証が正しく動作しない
  devise_for :users
  ## API 向けのトークン認証 (ヘッダーに access-token, client, uid を送る) 用ルートを作る
  namespace :v1, defaults: { format: :json } do     ##  👈/v1/auth/... にアクセスしたとき、Rails が自動的に JSON として扱う
    mount_devise_token_auth_for "User", at: "auth", controllers: {
        sessions: 'v1/auth/sessions', registrations: 'v1/auth/registrations'
    }
    resources :skills
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "health#show"
end
