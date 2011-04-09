ActionController::Routing::Routes.draw do |map|
  map.resources :sites

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "sites"

  #map.post 'post/:id', :controller => 'post', :action => 'show'

  map.browse_key_me   'browser/key_me/:pmodule/:id/:me',  :controller => 'browse', :action => 'key'
  map.browse_key_me_with   'browser/key_with/:pmodule/:id/:me/:with',  :controller => 'browse', :action => 'key'
  map.browse_key   'browser/key/:pmodule/:id',            :controller => 'browse', :action => 'key'
  map.browse_value 'browser/value/:pmodule/:key/:id',     :controller => 'browse', :action => 'value'
  
  # See how all your routes lay out with "rake routes"
  map.connect 'sites/compare/:id/:with', :controller => "sites", :action => "compare"
  
  map.connect 'browser/key_with/:pmodule/:id/:me',  :controller => 'browse',    :action => :key  
  map.connect 'browser/key_me/:pmodule/:id/:me',  :controller => 'browse',    :action => :key
  map.connect 'browser/key/:pmodule/:id',         :controller => "browse",    :action => :key
  map.connect 'browser/value/:pmodule/:key/:id',  :controller => "browse",    :action => :value
  
  map.connect 'phpinfo/:id', :controller => "sites", :action => "phpinfo"
  # Install the default routes as the lowest priority.
  #

  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id/:with'
  map.connect ':controller/:action/:id.:format'
end
