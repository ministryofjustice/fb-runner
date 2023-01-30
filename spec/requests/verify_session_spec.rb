RSpec.describe 'verify session', type: :request do
  let(:session_expired_path) { '/session/expired' }

  context 'when session id exists' do
    before do
      allow_any_instance_of(
        ActionDispatch::Request
      ).to receive(:session).and_return(
        { session_id: SecureRandom.hex(24) }
      )
    end

    context 'when other page' do
      before do
        get '/name'
      end

      it 'does not redirect the user' do
        expect(response).to_not redirect_to(session_expired_path)
      end
    end
  end

  context 'when session id is blank' do
    context 'when root path' do
      before do
        get '/'
      end

      it 'does not redirect the user' do
        expect(response).to_not redirect_to(session_expired_path)
      end
    end

    context 'when standalone page' do
      before do
        get '/cookies'
      end

      it 'does not redirect the user' do
        expect(response).to_not redirect_to(session_expired_path)
      end
    end

    context 'when other page' do
      before do
        get '/name'
      end

      it 'redirects the user' do
        expect(response).to redirect_to(session_expired_path)
      end
    end
  end
end
