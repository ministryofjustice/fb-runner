RSpec.describe 'verify session', type: :request do
  let(:session_expired_path) { '/session/expired' }

  context 'when session id exists' do
    let(:dummy_session) do
      {
        session_id: SecureRandom.hex(24),
        user_id: 'eb380609ce7706bb930b5991c8acc51f',
        expire_after: 2.minutes,
        user_data:
          {
            'num_number_1' => '42',
            'email_email_1' => 'e@mail.com',
            'moj_forms_reference_number' => 'TX4-KHM5-JTN'
          }
      }
    end

    context 'when other page' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(dummy_session)
        get '/name'
      end
      it 'does not redirect the user' do
        expect(response).to_not redirect_to(session_expired_path)
      end

      it 'extends the session expiry' do
        expect(dummy_session[:expire_after]).to eq(20.minutes)
      end
    end

    context 'when we reach the end of the form and submit' do
      before do
        allow(controller).to receive(:session).and_return(:dummy_session)
        get '/form-sent'
      end

      it 'redirects the user to timeout page' do
        expect(response).to redirect_to(session_expired_path)
      end

      it 'and has cleared the user session' do
        expect(controller.session[:user_data]).to be_falsey
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
