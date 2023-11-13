RSpec.describe Platform::UserDatastoreAdapter do
  subject(:adapter) do
    described_class.new(session, root_url:, service_slug:)
  end

  let(:service_slug) { 'court-service' }
  let(:root_url) do
    'http://user-datastore.com'
  end
  let(:expected_url) do
    URI.join(root_url, '/service/court-service/user/60abfdea862c0c6d7aa737aec6e805fa')
  end
  let(:expected_headers) do
    {
      'Authorization' => 'Bearer some-token',
      'x-access-token-v2' => 'some-token',
      'X-Request-Id' => '12345',
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Runner'
    }
  end
  let(:service_access_token) { 'some-token' }

  let(:expected_body) do
    JSON.generate({
      payload: data_encryption.encrypt(params.to_json)
    })
  end

  let(:params) do
    { question_one: 'Be careful not to choke on your aspirations.' }
  end
  let(:session) do
    {
      user_id: '60abfdea862c0c6d7aa737aec6e805fa',
      user_token: '474c39bf61287d4ec0aa1276f089d2e3',
      saved_form: {
        'field' => 'value',
        'email' => 'email@email.com',
        'user_id' => 'userid',
        'user_token' => 'some_token',
        'secret_answer' => 'a cool secret'
      }
    }
  end
  let(:request_double) { double(request_id: '12345') }
  let(:empty_payload) do
    JSON.generate({ payload: data_encryption.encrypt('{}') })
  end

  let(:saved_forms_encryption_key) { 'qwertyqwertyqwertyqwertyqwertyqw' }
  let(:data_encryption) { DataEncryption.new(key: session[:user_token]) }
  let(:saved_form_data_encryption) { DataEncryption.new(key: saved_forms_encryption_key) }

  before do
    session.instance_variable_set(:@req, request_double)

    allow_any_instance_of(Fb::Jwt::Auth::ServiceAccessToken).to receive(:generate)
      .and_return(service_access_token)

    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SUBMISSION_ENCRYPTION_KEY').and_return(saved_forms_encryption_key)
  end

  describe '#save' do
    context 'when the response is successful' do
      context 'when there is data already stored in datastore' do
        let(:existing_answers) do
          { other_question: 'Do. Or do not. There is no try.' }
        end
        let(:expected_body) do
          JSON.generate(
            {
              payload: data_encryption.encrypt(existing_answers.merge(params).to_json)
            }
          )
        end

        before do
          expect(adapter).to receive(:load_data).and_return(existing_answers)

          stub_request(:post, expected_url)
            .with(body: expected_body, headers: expected_headers)
            .to_return(status: 200, body: expected_body, headers: {})
        end

        it 'merges the whole payload and send to datastore' do
          adapter.save(params)
          expect(WebMock).to have_requested(
            :post, expected_url
          ).with(headers: expected_headers, body: expected_body)
           .once
        end
      end

      context 'when there is no data stored in datastore' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 404, body: empty_payload, headers: {})

          stub_request(:post, expected_url)
            .with(body: expected_body, headers: expected_headers)
            .to_return(status: 201, body: expected_body, headers: {})
        end

        it 'sends request to datastore' do
          adapter.save(params)
          expect(WebMock).to have_requested(
            :post, expected_url
          ).with(headers: expected_headers, body: expected_body)
           .once
        end
      end
    end

    context 'when the response fails' do
      before do
        stub_request(:get, expected_url)
          .with(body: {}, headers: expected_headers)
          .to_return(status: 500, body: JSON.generate({}), headers: {})
      end

      it 'raises datastore error' do
        expect { adapter.save(params) }.to raise_error(
          Platform::ClientError
        )
      end
    end

    context 'when there is timeout' do
      context 'when there is connection timeout' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_timeout
        end

        it 'raises datastore timeout error' do
          expect { adapter.save(params) }.to raise_error(
            Platform::TimeoutError
          )
        end
      end

      context 'when there is request timeout' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_raise(Faraday::TimeoutError)
        end

        it 'raises datastore timeout error' do
          expect { adapter.save(params) }.to raise_error(
            Platform::TimeoutError
          )
        end
      end
    end
  end

  describe '#load_data' do
    context 'when returning data' do
      before do
        stub_request(:get, expected_url)
          .with(body: {}, headers: expected_headers)
          .to_return(status: 200, body: expected_body, headers: {})
      end

      it 'returns decrypted payload' do
        expect(adapter.load_data).to eq(params.stringify_keys)
      end
    end

    context 'when there is no data in payload (when user starts the form)' do
      before do
        stub_request(:get, expected_url)
          .with(body: {}, headers: expected_headers)
          .to_return(status: 200, body: empty_payload, headers: {})
      end

      it 'returns empty hash' do
        expect(adapter.load_data).to eq({})
      end
    end
  end

  describe '#delete' do
    let(:existing_answers) { { 'component_id' => {} } }
    let(:params) { {} }
    let(:expected_body) do
      JSON.generate(
        {
          payload: data_encryption.encrypt({}.merge(params).to_json)
        }
      )
    end

    before do
      expect(adapter).to receive(:load_data).and_return(existing_answers)

      stub_request(:post, expected_url)
        .with(body: expected_body, headers: expected_headers)
        .to_return(status: 200, body: expected_body, headers: {})
    end

    it 'removes the user data' do
      expect(adapter.delete('component_id').body).to eq(JSON.parse(expected_body))
    end
  end

  describe '#save_progress' do
    let(:expected_response_body) { JSON.generate({ id: 'i-am-a-uuid' }) }
    let(:expected_url) do
      URI.join(root_url, '/service/court-service/saved/')
    end
    let(:params) do
      { question_one: 'Be careful not to choke on your aspirations.' }
    end
    let(:expected_body) do
      cloned_session = session[:saved_form].clone
      cloned_session['email'] = saved_form_data_encryption.encrypt(cloned_session['email'])
      cloned_session['user_token'] = saved_form_data_encryption.encrypt(cloned_session['user_token'])
      cloned_session['user_id'] = saved_form_data_encryption.encrypt(cloned_session['user_id'])
      cloned_session['secret_answer'] = saved_form_data_encryption.encrypt(cloned_session['secret_answer'])
      JSON.generate(
        cloned_session
      )
    end

    before do
      stub_request(:post, expected_url)
        .with(body: expected_body, headers: expected_headers)
        .to_return(status: 200, body: expected_response_body, headers: {})
    end

    it 'saves the object' do
      expect(adapter.save_progress.body).to eq(JSON.parse(expected_response_body))
    end
  end

  describe '#get_saved_progress' do
    let(:uuid) { SecureRandom.uuid }
    let(:encrypted_response_body) do
      JSON.generate({
        id: uuid,
        user_id: saved_form_data_encryption.encrypt('1234'),
        user_token: saved_form_data_encryption.encrypt('token'),
        email: saved_form_data_encryption.encrypt('email@email.com'),
        secret_answer: saved_form_data_encryption.encrypt('a cool secret')
      })
    end
    let(:expected_response_body) do
      JSON.generate({
        id: uuid,
        user_id: '1234',
        user_token: 'token',
        email: 'email@email.com',
        secret_answer: 'a cool secret'
      })
    end

    let(:expected_url) do
      URI.join(root_url, "/service/court-service/saved/#{uuid}")
    end

    before do
      stub_request(:get, expected_url)
        .with(body: {}, headers: expected_headers)
        .to_return(status: 200, body: encrypted_response_body, headers: {})
    end

    it 'gets the saved form by uuid' do
      expect(adapter.get_saved_progress(uuid).body).to eq(JSON.parse(expected_response_body))
    end

    context 'error codes' do
      context '400 (too many attempts)' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 400, body: {}.to_json, headers: {})
        end

        it 'returns the response with code and empty body' do
          expect(adapter.get_saved_progress(uuid).status).to eq(400)
        end
      end

      context '422 (already used)' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 422, body: {}.to_json, headers: {})
        end

        it 'returns the response with code and empty body' do
          expect(adapter.get_saved_progress(uuid).status).to eq(422)
        end
      end

      context '404 (record deleted)' do
        before do
          stub_request(:get, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 404, body: {}.to_json, headers: {})
        end

        it 'returns the response with code and empty body' do
          expect(adapter.get_saved_progress(uuid).status).to eq(404)
        end
      end
    end
  end

  describe '#increment_record_counter' do
    let(:uuid) { SecureRandom.uuid }

    let(:expected_url) do
      URI.join(root_url, "/service/court-service/saved/#{uuid}/increment")
    end

    before do
      stub_request(:post, expected_url)
        .with(body: {}, headers: expected_headers)
        .to_return(status: 200, body: {}.to_json, headers: {})
    end

    it 'increments the record counter' do
      expect(adapter.increment_record_counter(uuid).status).to eq(200)
    end

    context 'record already invalidated' do
      context 'because it has been deleted' do
        before do
          stub_request(:post, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 404, body: {}.to_json, headers: {})
        end

        it 'captures the error and returns a usable status' do
          expect(adapter.increment_record_counter(uuid).status).to eq(404)
        end
      end

      context 'because it has been used or attempted too many times' do
        before do
          stub_request(:post, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 422, body: {}.to_json, headers: {})
        end

        it 'captures the error and returns a usable status' do
          expect(adapter.increment_record_counter(uuid).status).to eq(422)
        end
      end
    end
  end

  describe '#invalidate' do
    let(:uuid) { SecureRandom.uuid }

    let(:expected_url) do
      URI.join(root_url, "/service/court-service/saved/#{uuid}/invalidate")
    end

    before do
      stub_request(:post, expected_url)
        .with(body: {}, headers: expected_headers)
        .to_return(status: 202, body: {}.to_json, headers: {})
    end

    it 'invalidates the record' do
      expect(adapter.invalidate(uuid).status).to eq(202)
    end

    context 'record already invalidated' do
      context 'because it has been deleted' do
        before do
          stub_request(:post, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 404, body: {}.to_json, headers: {})
        end

        it 'captures the error and returns a usable status' do
          expect(adapter.invalidate(uuid).status).to eq(404)
        end
      end

      context 'because it has been used or attempted too many times' do
        before do
          stub_request(:post, expected_url)
            .with(body: {}, headers: expected_headers)
            .to_return(status: 422, body: {}.to_json, headers: {})
        end

        it 'captures the error and returns a usable status' do
          expect(adapter.invalidate(uuid).status).to eq(422)
        end
      end
    end
  end
end
