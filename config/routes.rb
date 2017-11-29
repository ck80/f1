Rails.application.routes.draw do
  devise_for :admins, path: 'admin', skip: :registrations
  devise_for :users
  resources :leaderboards
  resources :users
  resources :tips
  resources :races
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

  root to: "tips#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end