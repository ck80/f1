Rails.application.routes.draw do
  get 'home/index'

  devise_for :admins, path: 'admin', skip: :registrations
  devise_for :users, :controllers => {:registrations => "users/registrations"}
  resources :leaderboards
  resources :users
  resources :tips
  resources :races
  resources :home
  resources :race_results do
    collection do
      post 'getraceresults'
    end
  end 
  resources :quali_results do
    collection do
      post 'getqualiresults'
    end
  end 
  resources :drivers
  get '/tipper/:name', to: 'tips#index', as: 'tipper'
  post 'home/action'
  root to: "leaderboards#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end