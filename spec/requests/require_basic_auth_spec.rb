RSpec.describe 'require basic auth', type: :request do
  context 'when username and password exist' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('BASIC_AUTH_USER').and_return('somethinginteresting')
      allow(ENV).to receive(:[]).with('BASIC_AUTH_PASS').and_return('somethingboring')
    end

    it 'redirects to the auth page' do
      get '/'
      expect(response).to redirect_to('/auth')
    end
  end

  context 'when session is authorised' do
    before do
      allow(controller).to receive(:session_authorised?).and_return(true)
    end

    it 'returns success' do
      get '/'
      expect(response.status).to eq(200)
    end

    it 'skips the auth page' do
      get '/auth'
      expect(response).to redirect_to('/')
    end
  end

  context 'when username and/or password are not set' do
    it 'returns success' do
      get '/'
      expect(response.status).to eq(200)
    end
  end
end
