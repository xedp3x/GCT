class Subdomain
  def self.matches?(request)
    case request.subdomain
    when 'www', '', nil
      false
    else
      true
    end
  end
end

class Rootdomain
  def self.matches?(request)
    case request.subdomain
    when 'www', '', nil
      true
    else
      false
    end
  end
end



GCT::Application.routes.draw do
  
  constraints(Subdomain) do
    root :to => 'groups#show'

    match '/p' => 'pads#new', :via => :post
    match '/p/:pad' => 'pads#delete', :via => :delete
    match '/p' => 'pads#index', :via => :get
    match '/p/:pad' => 'pads#show', :via => :get
  end

  constraints(Rootdomain) do
    root :to => 'user#index', :as => 'main'

    resources :people
    resources :groups

    match '/p/:pad' => 'pads#show', :via => :get
    match '/p' => 'home#pads', :via => :get

    match '/logout' => 'user#logout', :via => :all
    match '/login(/:uid)' => 'user#auth', :via => :all
    match '/token/:uid/:token' => 'user#token', :via => :all
  end
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
