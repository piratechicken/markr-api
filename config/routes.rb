Rails.application.routes.draw do
  post 'import', to: 'test_results#import'
  get 'results/:test_id/aggregate', to: 'test_results#aggregate'
end
