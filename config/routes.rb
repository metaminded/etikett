Rails.application.routes.draw do
  namespace :etikett do
    resources :tags, except: [:show]
  end
end
