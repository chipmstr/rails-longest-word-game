Rails.application.routes.draw do
  # route for displaying the letter grid (new game)
  get 'games/new', to: 'games#new'

  # route for submitting and processing the word (score calculation)
  post 'games/score', to: 'games#score'

  # existing route for health check
  get "up" => "rails/health#show", as: :rails_health_check

  # setting the root route to the games#new action
  root to: 'games#new'
end
