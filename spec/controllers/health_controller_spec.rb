RSpec.describe HealthController do
  describe 'GET #show' do
    it 'returns 200 OK' do
      get :show
      expect(response.status).to eq(200)
    end

    it 'returns healthy body' do
      get :show
      expect(response.body).to eq('healthy')
    end
  end
end
