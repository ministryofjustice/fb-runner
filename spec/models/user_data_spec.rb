RSpec.describe UserData do
  subject(:user_data) { described_class.new(session, adapter:) }
  let(:session) { {} }
  let(:adapter) do
    class MyCustomAdapter
      def initialize(session); end

      def save(params); end

      def load_data; end

      def delete(params); end
    end

    MyCustomAdapter
  end
  let(:params) { { some_question: 'some_answer' } }

  describe '#adapter' do
    context 'when adapter is overwritten in the initialise' do
      subject(:user_data) { described_class.new(session, adapter:) }

      it 'returns the adapter passed in initialize' do
        expect(user_data.adapter).to be_instance_of(adapter)
      end
    end

    context 'when there is a datastore url' do
      subject(:user_data) { described_class.new(session) }

      before do
        allow(ENV).to receive(:[]).with('USER_DATASTORE_URL')
          .and_return('http://localhost:9000')

        allow(ENV).to receive(:[]).with('SERVICE_SLUG')
          .and_return('court-or-tribunal')

        allow(ENV).to receive(:[]).with('SAVED_FORMS_KEY')
        .and_return('cqwertyqwertyqwertyqweertyqwerty')
      end

      it 'returns the datastore adapter' do
        expect(user_data.adapter).to be_instance_of(
          Platform::UserDatastoreAdapter
        )
      end

      it 'sets user token before calling the adapter' do
        allow(SecureRandom).to receive(:hex)
          .and_return('975e146ab6fe0a2e25fe224f404d11e6')
        user_data.adapter
        expect(session[:user_token]).to eq('975e146ab6fe0a2e25fe224f404d11e6')
      end

      it 'sets user id before calling the adapter' do
        allow(SecureRandom).to receive(:hex)
          .and_return('c39aefa9dd3987097742d33df99070d4')
        user_data.adapter
        expect(session[:user_id]).to eq('c39aefa9dd3987097742d33df99070d4')
      end
    end

    context 'when there is a user token and an user id' do
      let(:session) do
        {
          user_token: '6dd78844fb69d634f22143401cfb1851',
          user_id: '192ba011389fe2f15039b3b717a754f9'
        }
      end

      before do
        user_data.adapter
      end

      it 'keep same user id' do
        expect(session[:user_id]).to eq('192ba011389fe2f15039b3b717a754f9')
      end

      it 'keep same user token' do
        expect(session[:user_token]).to eq('6dd78844fb69d634f22143401cfb1851')
      end
    end

    context 'when no adapter is passed and there is no datastore url' do
      subject(:user_data) { described_class.new(session) }

      before do
        allow(ENV).to receive(:[]).with('USER_DATASTORE_URL').and_return('')
        allow(Rails.env).to receive(:production?).and_return(production?)
      end

      context 'when is production' do
        let(:production?) { true }

        it 'raises an error' do
          expect {
            user_data.adapter
          }.to raise_error(MissingDatastoreUrlError)
        end
      end

      context 'when is not production' do
        let(:production?) { false }

        it 'returns the session adapter' do
          expect(user_data.adapter).to be_instance_of(SessionDataAdapter)
        end
      end
    end
  end

  describe '#save' do
    it 'delegates to adapter' do
      expect_any_instance_of(adapter).to receive(:save).with(params)
      user_data.save(params)
    end
  end

  describe '#delete' do
    it 'delegates to adapter' do
      expect_any_instance_of(adapter).to receive(:delete).with(params)
      user_data.delete(params)
    end
  end

  describe '#load_data' do
    it 'delegates to adapter' do
      expect_any_instance_of(adapter).to receive(:load_data)
      user_data.load_data
    end
  end
end
