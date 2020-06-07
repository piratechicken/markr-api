require 'rails_helper'

RSpec.describe TestResultsController, type: :routing do
  describe 'routing' do
    it 'routes to #import' do
      expect(post: '/import').to route_to('test_results#import')
    end
  end
end
