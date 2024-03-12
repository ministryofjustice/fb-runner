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

    context 'show warning depending on environment' do
      let(:warning_text) { I18n.t('presenter.authorisation.warning') }

      before do
        allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return(platform_env)
        allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return(deployment_env)

        get '/'
        follow_redirect!
      end

      context 'test-production' do
        let(:platform_env) { 'test' }
        let(:deployment_env) { 'production' }

        it 'shows the warning' do
          assert_select 'div.govuk-warning-text', /#{warning_text}/
        end
      end

      context 'live-production' do
        let(:platform_env) { 'live' }
        let(:deployment_env) { 'production' }

        it 'does not show the warning' do
          assert_select 'div.govuk-warning-text', count: 0, text: /#{warning_text}/
        end
      end
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
