# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # ローカル開発 + Firebase Hosting + Cloud Run 旧フロント（origin 変更時は rails-api を再デプロイ）
    origins "http://localhost:5173",
            "https://ishii-portfolio.web.app",
            "https://ishii-portfolio.firebaseapp.com",
            "https://react-rails-885483537018.asia-northeast1.run.app"
    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: %w[access-token expiry token-type uid client]  # クライアントで参照したいヘッダ
  end
end
