Rails.application.routes.draw do
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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
