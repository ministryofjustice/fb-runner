RSpec.describe Platform::UserFilestoreAdapter do
  subject(:adapter) do
    described_class.new(
      session,
      root_url: root_url,
      service_slug: service_slug,
      payload: payload
    )
  end
  let(:session) { double(id: 'some-id') }
  let(:root_url) { 'http://filestore-svc' }
  let(:service_slug) { 'juggling-license' }
  let(:payload) { {} }

  describe '#call' do
    context 'when there is filestore url' do
      let(:expected_url) do
        "#{root_url}/service/#{service_slug}/user/#{session.id}"
      end
      let(:expected_payload) do
        {
          "encrypted_user_id_and_token": '12345678901234567890123456789012',
          "file": encoded_file,
          "policy": {
            "allowed_types": allowed_types,
              "max_size": MAX_FILE_SIZE,
              "expires": expires
          }
        }
      end
      let(:expected_headers) do
        {
          'Content-Type': 'application/JSON',
          'x-access-token': {

          }
        }
      end
      let(:response_body) do
        {
          "url": "/service/{service_slug}/{user_id}/{fingerprint}",
          "size": "<integer>(bytes)",
          "type": "<string>(mediatype)",
          "date": "<integer>(unix_timestamp)"
        }

        "{\"url\":\"/service/some-service/user/some-user/28d-e71c352d0852ab802592a02168877dc255d9c839a7537d91efed04a5865549c1\",\"size\":173,\"type\":\"image/png\",\"date\":1554734786}"
      end

      before do
        stub_request(:post, expected_url)
          .with(body: expected_payload, headers: expected_headers)
          .to_return(status: 201, body: response_body, headers: {})
      end

      it 'makes a request to filestore' do
        adapter.call
        expect(WebMock).to have_requested(
          :post, expected_url
        ).with(headers: expected_headers, body: expected_payload)
         .once
      end
    end

    context 'when there is not filestore url' do
      it 'returns nil' do
        expect(adapter.call).to be_nil
      end
    end

    context 'when there is no encrypted user id and token in the payload' do
      # Error if encrypted_user_id_and_token property is not present
      # code: 403
      # name: forbidden.user-id-token-missing
    end

    context 'when the file is too large' do
      # Perform size check if policy.max_size is present
      # Error if file is too large
      # code: 400
      # name: invalid.too-large
      # max_size: {max_size}
      # size: {file_size}
    end

    context 'when the file type is not allowed' do
      # Perform file type checks if policy.allowed_types is present
      # Error if file is wrong type
      # code: 400
      # name: invalid.type
      # type: {file_type}
    end

    context 'when there is a virus' do
      # Send to virus scanning service
      # Error if file contains virus
      # code: 400
      # name: invalid.virus
      # virus_name: {virus_name}
    end
  end
end
