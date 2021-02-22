RSpec.describe Platform::SubmitterAdapter do
  subject(:adapter) do
    described_class.new(
      payload: payload,
      root_url: root_url
    )
  end
  let(:root_url) do
    'http://submitter.com'
  end

  describe '#save' do
    let(:payload) do
      {
        some: :payload
      }
    end
    let(:expected_url) { "#{root_url}/v2/submissions" }
    let(:expected_headers) do
      {
        'Authorization' => 'Bearer some-token',
        'x-access-token-v2' => 'some-token',
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Runner'
      }
    end
    let(:expected_body) do
      {
        encrypted_submission: DataEncryption.new(key: key).encrypt(
          JSON.generate(payload)
        )
      }
    end
    let(:key) do
      SecureRandom.uuid[0..31]
    end

    before do
      allow_any_instance_of(Fb::Jwt::Auth::ServiceAccessToken).to receive(:generate)
        .and_return('some-token')

      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SUBMISSION_ENCRYPTION_KEY')
        .and_return(key)
    end

    it 'sends to submitter with the right payload' do
      stub_request(:post, expected_url)
        .with(body: expected_body, headers: expected_headers)
        .to_return(status: 201, body: '{}', headers: {})
      adapter.save
      expect(WebMock).to have_requested(
        :post, expected_url
      ).with(headers: expected_headers, body: expected_body)
       .once
    end
  end
end
