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
    let(:service_email_pdf_heading) { 'Middle earth news' }
    let(:service_email_pdf_subheading) { 'BREAKING NEWS' }
    let(:service_email_sender) { 'bilbo@middle-earth.uk' }
    let(:service_email_subject) { 'Erebor' }
    let(:service_email_body) { 'Ah, Frodo. Erebor.' }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_HEADING')
        .and_return(service_email_pdf_heading)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_SUBHEADING')
        .and_return(service_email_pdf_subheading)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT')
        .and_return(service_email_output)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_SENDER')
        .and_return(service_email_sender)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_SUBJECT')
        .and_return(service_email_subject)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_BODY')
        .and_return(service_email_body)
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
