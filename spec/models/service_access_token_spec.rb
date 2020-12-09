RSpec.describe ServiceAccessToken do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:encoded_private_key) do
    Base64.strict_encode64(private_key.to_s)
  end
  let(:public_key) { private_key.public_key }
  let(:current_time) { Time.new(2020, 12, 7, 16) }

  describe '#generate' do
    let(:platform_env) { nil }
    let(:deployment_env) { nil }
    let(:service_token) do
      ServiceAccessToken.new(subject: subject, encoded_private_key: encoded_private_key, platform_env: platform_env, deployment_env: deployment_env)
    end

    before do
      allow(Time).to receive(:current).and_return(current_time)
    end

    context 'when private key is blank' do
      let(:encoded_private_key) { {} }
      let(:subject) { nil }

      it 'returns nil' do
        expect(service_token.generate).to eq('')
      end
    end

    context 'when there is a subject' do
      let(:subject) { 'user-id-123' }

      it 'generates jwt access token with a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => current_time.to_i,
            'iss' => 'fb-runner',
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
            'iat' => current_time.to_i,
            'iss' => 'fb-runner'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end

    context 'when there is a namespace' do
      let(:subject) { nil }
      let(:platform_env) { 'test' }
      let(:deployment_env) { 'dev' }

      it 'generate jwt access token without a sub' do
        expect(
          JWT.decode(service_token.generate, public_key, true, { algorithm: 'RS256' })
        ).to eq([
          {
            'iat' => current_time.to_i,
            'iss' => 'fb-runner',
            'namespace' => 'formbuilder-services-test-dev'
          },
          {
            'alg' => 'RS256'
          }
        ])
      end
    end
  end
end
