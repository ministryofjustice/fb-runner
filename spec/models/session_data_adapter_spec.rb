RSpec.describe SessionDataAdapter do
  subject(:adapter) { described_class.new(session) }

  describe '#save' do
    context 'when there is answers' do
      let(:params) do
        { question_1: 'Even the very wise cannot see all ends' }
      end
      let(:session) { {} }

      it 'add answers to the session' do
        adapter.save(params)
        expect(session).to eq(user_data: params)
      end
    end

    context 'when there is no answers' do
      let(:params) { {} }
      let(:session) do
        { question_1: "I'm a Mandalorian. Weapons are part of my religion." }
      end

      it 'returns nil' do
        expect(adapter.save(params)).to be(nil)
      end

      it 'does not change the session' do
        expect(session.keys.size).to be(1)
      end
    end
  end

  describe '#load_data' do
    context 'when there is user data' do
      let(:session) do
        {
          user_data: {
            question_1: 'If in doubt, meriadoc, always follow your nose!'
          }
        }
      end

      it 'returns user data' do
        expect(adapter.load_data).to eq(session[:user_data])
      end
    end

    context 'when there is no user data' do
      let(:session) { {} }

      it 'returns empty' do
        expect(adapter.load_data).to eq({})
      end
    end
  end
end
