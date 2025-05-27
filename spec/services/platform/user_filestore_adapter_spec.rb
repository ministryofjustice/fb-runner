RSpec.describe Platform::UserFilestoreAdapter do
  subject(:adapter) do
    described_class.new(
      session:,
      file_details:,
      allowed_file_types:,
      root_url:,
      service_slug:
    )
  end
  let(:file_details) { { original_filename: 'this-is-a-knife.png' } }
  let(:allowed_file_types) { %w[long-list-of-alllowed-types] }
  let(:root_url) { 'http://filestore-svc' }
  let(:service_slug) { 'juggling-license' }
  let(:payload) do
    {
      'encrypted_user_id_and_token': '12345678901234567890123456789012',
      'file': encoded_file,
      'policy': {
        'allowed_types': Platform::UserFilestorePayload::ALLOWED_TYPES,
        'max_size': Platform::UserFilestorePayload::MAX_FILE_SIZE,
        'expires': Platform::UserFilestorePayload::DEFAULT_EXPIRATION
      }
    }
  end
  let(:encoded_file) do
    Base64.strict_encode64("THIS IS A KNIFE!\n")
  end
  let(:expected_headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Bearer',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Runner',
      'X-Request-Id' => '12345',
      'X-Access-Token-V2' => ''
    }
  end
  let(:session) { { user_id: 'bassetthegodfather' } }
  let(:request_double) { double(request_id: '12345') }
  let(:expected_url) do
    "#{root_url}/service/#{service_slug}/user/#{session[:user_id]}"
  end
  let(:response_body) { '{}' }
  let(:response_status) { 201 }

  before do
    session.instance_variable_set(:@req, request_double)

    allow(Platform::UserFilestorePayload).to receive(:new).with(
      session:,
      file_details:,
      allowed_file_types:
    ).and_return(double(call: payload))
    stub_request(:post, expected_url)
      .with(body: payload, headers: expected_headers)
      .to_return(status: response_status, body: response_body, headers: {})
  end

  describe '#call' do
    RSpec.shared_context 'filestore_error_response' do
      it 'returns an error response' do
        expect(adapter.call.error?).to be_truthy
      end

      it 'assigns the status' do
        expect(adapter.call.status).to be(response_status)
      end

      it 'assigns the response body' do
        expect(adapter.call.error_name).to eq(error_name)
      end
    end

    context 'when there is filestore url' do
      let(:response_body) do
        JSON.generate({
          'url': '/service/{service_slug}/{user_id}/{fingerprint}',
          'size': '<integer>(bytes)',
          'type': '<string>(mediatype)',
          'date': '<integer>(unix_timestamp)'
        })
      end

      it 'makes a request to filestore' do
        adapter.call
        expect(WebMock).to have_requested(
          :post, expected_url
        ).with(headers: expected_headers, body: payload)
         .once
      end
    end

    context 'when there is not filestore url' do
      let(:root_url) { nil }

      it 'returns nil' do
        expect(adapter.call).to be_nil
      end
    end

    context 'when there is no encrypted_user_id_and_token in the payload' do
      include_context 'filestore_error_response' do
        let(:response_body) do
          JSON.generate({
            code: 403,
            name: 'forbidden.user-id-token-missing'
          })
        end
        let(:response_status) { 403 }
        let(:error_name) { 'forbidden.user-id-token-missing' }
      end
    end

    context 'when the file is too large' do
      include_context 'filestore_error_response' do
        let(:response_body) do
          JSON.generate({
            code: 400,
            name: 'invalid.too-large'
          })
        end
        let(:response_status) { 400 }
        let(:error_name) { 'invalid.too-large' }
      end
    end

    context 'when the file type is not allowed' do
      include_context 'filestore_error_response' do
        let(:response_body) do
          JSON.generate({
            code: 400,
            name: 'invalid.type'
          })
        end
        let(:response_status) { 400 }
        let(:error_name) { 'invalid.type' }
      end
    end

    context 'when there is a virus' do
      include_context 'filestore_error_response' do
        let(:response_body) do
          JSON.generate({
            code: 400,
            name: 'invalid.virus'
          })
        end
        let(:response_status) { 400 }
        let(:error_name) { 'invalid.virus' }
      end
    end

    context 'when the request times out' do
      include_context 'filestore_error_response' do
        let(:response_body) do
          JSON.generate({
            code: 408,
            name: 'timeout'
          })
        end
        let(:response_status) { 408 }
        let(:error_name) { 'timeout' }
      end
    end
  end
end
