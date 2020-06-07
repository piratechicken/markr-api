Rails.application.routes.draw do
  post 'import', to: 'test_results#import'
end
