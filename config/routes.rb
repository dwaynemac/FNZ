ActionController::Routing::Routes.draw do |map|

  map.resources :imports, :member => { :load_data => :get }

  map.resources :accounts, :has_many => :transactions
  map.resources :transactions, :new => { :transfer => :any }
  map.resources :users, :has_many => [:transactions, :schools]

  map.resources :concepts

  map.resources :oauth_consumers,:member=>{:callback=>:get}
  map.unauthorized '/unauthorized', :controller => :user_sessions, :action => :unauthorized
  map.logout '/logout', :controller => :user_sessions, :action => :destroy

  map.welcome '/welcome', :controller => :main, :action => :welcome
  map.root :controller => 'main', :action => 'index'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
