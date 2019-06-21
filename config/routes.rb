Rails.application.routes.draw do
  root to: "incidents#filter"
  get 'incidents/type_count', to: 'incidents#type_count'
  get 'incidents/term_count', to: 'incidents#term_count'
  get 'incidents/username_count', to: 'incidents#username_count'
  get 'incidents/filter', to: 'incidents#filter'
  get 'incidents/analysis', to: 'incidents#analysis'

  resources :choices
  resources :incidents do
    member do
      delete 'delete_picture',   to: "incidents#delete_picture"
      get    'download_picture', to: "incidents#download_picture"
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
