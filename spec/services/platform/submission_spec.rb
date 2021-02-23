RSpec.describe Platform::Submission do
  subject(:submission) do
    described_class.new(service: service, user_data: user_data)
  end
  let(:user_data) { {} }

  describe '#save' do
    before do
      allow(submission).to receive(:invalid?).and_return(invalid)
    end

    context 'when valid' do
      let(:invalid) { false }

      it 'sends the submission' do
        expect_any_instance_of(Platform::SubmitterAdapter).to receive(:save)
        submission.save
      end
    end

    context 'when invalid' do
      let(:invalid) { true }

      it 'does not send the submission' do
        expect_any_instance_of(Platform::SubmitterAdapter).to_not receive(:save)
        submission.save
      end
    end
  end

  describe '#valid?' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT')
        .and_return(service_email_output)
    end

    context 'when required env vars are present' do
      let(:service_email_output) { 'legolas@middle-earth.uk' }

      it 'returns valid' do
        expect(submission).to be_valid
      end
    end

    context 'when required env vars are blank' do
      let(:service_email_output) { nil }

      it 'returns invalid' do
        expect(submission).to_not be_valid
      end
    end
  end
end
