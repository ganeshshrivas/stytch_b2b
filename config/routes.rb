Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :admin do
    post 'users', to: 'users#create'  # protected admin endpoint
  end

  namespace :public do
    post 'magic_links', to: 'magic_links#create'      # request magic link
    get 'magic_links/authenticate', to: 'magic_links#authenticate'  # callback
  end
end
