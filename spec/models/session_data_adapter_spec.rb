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

  describe '#delete' do
    let(:session) do
      {
        user_data: {
          'dog-picture' => { 'original_filename' => 'basset-hound.png' }
        }
      }
    end

    it 'removes component from session' do
      expect(adapter.delete('dog-picture')).to eq({})
    end
  end

  describe 'save and return helpers' do
    let(:session) { {} }

    describe 'save progress' do
      it 'returns 200 when mocking save progress' do
        expect(adapter.save_progress.status).to eq(200)
        expect(adapter.save_progress.body[:id]).to be_truthy
      end
    end

    describe 'get saved progress' do
      it 'returns 404 if you match with notfound' do
        expect(adapter.get_saved_progress('notfound').status).to eq(404)
        expect(adapter.get_saved_progress('notfound').body).to eq({})        
      end

      it 'returns 422 if you match with inactive' do
        expect(adapter.get_saved_progress('inactive').status).to eq(422)
        expect(adapter.get_saved_progress('inactive').body).to eq({})        
      end

      it 'returns 400 if you match with attempted' do
        expect(adapter.get_saved_progress('attempted').status).to eq(400)
        expect(adapter.get_saved_progress('attempted').body).to eq({})        
      end

      it 'returns 200 if you match, and the version id matches the runner local metadata' do
        expect(adapter.get_saved_progress('match').status).to eq(200)
        expect(adapter.get_saved_progress('match').body['service_version']).to eq('27dc30c9-f7b8-4dec-973a-bd153f6797df')        
      end

      it 'returns 200 if you match anything else, and the version id does not match the runner local metadata' do
        expect(adapter.get_saved_progress('anything').status).to eq(200)
        expect(adapter.get_saved_progress('anything').body['service_version']).to_not eq('27dc30c9-f7b8-4dec-973a-bd153f6797df')        
      end
    end

    describe '#increment_record_counter' do
      it 'returns 200' do
        expect(adapter.increment_record_counter('anything').status).to eq(200)
      end
    end

    describe '#invalidate' do
      it 'returns 202' do
        expect(adapter.invalidate('anything').status).to eq(202)
      end
    end
  end
end
