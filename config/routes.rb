Rails.application.routes.draw do
  scope path: '/backend' do
    namespace :etikett do
      resources :tags, except: [:show]
    end
  end
end
