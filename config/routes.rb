ActionController::Routing::Routes.draw do |map|
  map.resources :people, :collection => { :in_padma => :get },
                         :has_many => :transactions



  map.resources :categories, :has_many => :transactions,
                             :member => { :subcategory => :get },
                             :collection => { :edit_multiple => :post, :update_multiple => :put }


  map.resources :imports, :member => { :load_data => :get }

  map.resources :accounts, :has_many => :transactions
  map.resources :transactions, :new => { :transfer => :any },
                               :collection => { :destroy_multiple => :delete }
  map.resources :incomes, :controller => :transactions # condition type is Income
  map.resources :expenses, :controller => :transactions # condition type is Expense
  map.resources :users, :has_many => [:transactions, :institutions]

  map.resources :concepts

  map.resources :oauth_consumers,:member=>{:callback=>:get}
  map.unauthorized '/unauthorized', :controller => :user_sessions, :action => :unauthorized
  map.logout '/logout', :controller => :user_sessions, :action => :destroy

  map.welcome '/welcome', :controller => :main, :action => :welcome
  map.root :controller => 'main', :action => 'index'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
