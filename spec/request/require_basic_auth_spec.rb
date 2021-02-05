RSpec.describe 'require basic auth', type: :request do
  context 'when username and password exist' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('BASIC_AUTH_USER').and_return('somethinginteresting')
      allow(ENV).to receive(:[]).with('BASIC_AUTH_PASS').and_return('somethingboring')
    end

    it 'returns forbidden' do
      get '/'
      expect(response.status).to eq(401)
    end
  end

  context 'when username and/or password are not set' do
    it 'returns success' do
      get '/'
      expect(response.status).to eq(200)
    end
  end
end
