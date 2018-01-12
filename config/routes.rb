Rails.application.routes.draw do
  devise_for :users, :controllers => {:registrations => "users/registrations"}
  resources :leaderboards
  resources :users
  scope ':year' do
    resources :tips
    resources :home
    post 'home/fetch_results_action'
    post 'home/fetch_results'
    post 'home/fetch_drivers'
    post 'home/fetch_races'
    post 'home/fetch_drivers_by_races'
    post 'home/update_points_table'
    post 'home/account_upgrade'
    post 'home/update_race_tip_points'
    post 'home/update_race_start'
  end
  resources :races
 # resources :home
  resources :points
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
  #get '/(:year)/tips', to: 'tips#index'

  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end