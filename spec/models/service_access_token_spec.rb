RSpec.describe ServiceAccessToken do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:encoded_private_key) do
    Base64.strict_encode64(private_key.to_s)
  end
  let(:public_key) { private_key.public_key }

  before do
    allow(ENV).to receive(:[])
      .with('ENCODED_PRIVATE_KEY').and_return(encoded_private_key)
  end

  describe '#generate' do
    let(:service_token) do
      ServiceAccessToken.new(subject: subject)
    end

    before do
      allow(Time).to receive(:current).and_return(Time.new(2020, 12, 7, 16))
    end

    context 'when private key is blank' do
      let(:encoded_private_key) { {} }
      let(:subject) { nil }

      it 'returns nil' do
        expect(service_token.generate).to be(nil)
      end
    end

    context 'when there is a subject' do
      let(:subject) { 'user-id-123' }

      it 'generates jwt access token with a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => 1607367600,
            'iss' => 'fb-runner',
            'namespace' => 'formbuilder-services-live-production',
            'sub' => 'user-id-123'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end

    context 'when there is no subject ' do
      let(:subject) { nil }

      it 'generate jwt access token without a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => 1607367600,
            'iss' => 'fb-runner',
            'namespace' => 'formbuilder-services-live-production'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end
  end
end
