require 'rails_helper'

RSpec.describe TestResultsController, type: :routing do
  describe 'routing' do
    it 'routes to #import' do
      expect(post: '/import').to route_to('test_results#import')
    end

    it 'routes to #aggregate' do
      expect(get: 'results/1/aggregate')
        .to route_to(controller: 'test_results', action: 'aggregate', test_id: '1')
    end
  end
end
