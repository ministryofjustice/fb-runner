RSpec.describe Platform::Submission do
  subject(:submission) do
    described_class.new(service:, user_data:, session:)
  end
  let(:user_data) { {} }
  let(:session) { {} }
  let(:service_slug) { 'version-fixture' }

  describe '#save' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_SLUG').and_return(service_slug)
      allow(submission).to receive(:invalid?).and_return(invalid)
    end

    context 'when valid' do
      let(:adapter) { double }
      let(:submitter_payload) { double }
      let(:payload) { { encrypted_submission: '' } }
      let(:invalid) { false }

      before do
        allow(Platform::SubmitterPayload).to receive(:new)
          .and_return(submitter_payload)
        allow(submitter_payload).to receive(:to_h).and_return(payload)
      end

      it 'sends the submission' do
        expect(Platform::SubmitterAdapter).to receive(:new)
          .with(session:, payload:, service_slug: ENV['SERVICE_SLUG'])
          .and_return(adapter)
        expect(adapter).to receive(:save)
        submission.save
      end
    end

    context 'when invalid' do
      let(:invalid) { true }

      before do
        allow(Rails.env).to receive(:production?).and_return(production?)
      end

      context 'when env is production' do
        let(:production?) { true }

        it 'raises an error' do
          expect {
            submission.save
          }.to raise_error(Platform::MissingSubmitterUrlError)
        end
      end

      context 'when env is not production' do
        let(:production?) { false }

        it 'does not send the submission' do
          expect_any_instance_of(Platform::SubmitterAdapter).to_not receive(:save)
          submission.save
        end
      end
    end
  end

  describe '#valid?' do
    let(:submitter_url) { 'http://fb-awesome-submitter' }
    let(:json_endpoint_url) { 'http://superb-api' }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_SLUG').and_return(service_slug)
      allow(ENV).to receive(:[]).with('SUBMITTER_URL').and_return(submitter_url)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT')
        .and_return(service_email_output)
      allow(ENV).to receive(:[]).with('SERVICE_OUTPUT_JSON_ENDPOINT').and_return(json_endpoint_url)
    end

    context 'when required env vars are present' do
      let(:service_email_output) { 'legolas@middle-earth.uk' }

      it 'returns valid' do
        expect(submission).to be_valid
      end
    end

    context 'when service email output and api-endpoint are blank' do
      let(:json_endpoint_url) { nil }
      let(:service_email_output) { nil }

      it 'returns invalid' do
        expect(submission).to_not be_valid
      end
    end

    context 'when service email output is blank but api-endpoint is set' do
      let(:service_email_output) { nil }

      it 'returns valid' do
        expect(submission).to be_valid
      end
    end

    context 'when submitter url is blank' do
      let(:service_email_output) { 'aragorn@middle-earth.uk' }
      let(:submitter_url) { nil }

      it 'returns invalid' do
        expect(submission).to_not be_valid
      end
    end
  end
end
