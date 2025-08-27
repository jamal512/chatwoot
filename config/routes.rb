# Inside the existing API namespace
namespace :api do
  namespace :v1 do
    resources :accounts, param: :id do
      resources :campaigns do
        member do
          post :execute
        end
      end
    end
  end
end
