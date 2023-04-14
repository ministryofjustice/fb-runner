RSpec.describe Platform::SaveAndReturnPayload do
  let(:session) { { user_id: 'user-id-5b10c947cf32bd0558318e77eebc0995' } }
  subject(:save_and_return_payload) do
    described_class.new(
      service:,
      user_data:,
      session:
    )
  end
  let(:user_data) do
    {
      'id' => 'some-id',
      'email' => 'middle.earth.entertainment@magazine.co.uk'
    }
  end
  let(:email_to) do
    'middle.earth.entertainment@magazine.co.uk'
  end
  let(:expected_email_from) do
    "Version Fixture <#{default_email_address}>"
  end
  let(:default_email_address) { Platform::SaveAndReturnPayload::DEFAULT_EMAIL_ADDRESS }
  let(:email_subject) do
    "Resuming your application to #{service.service_name}"
  end
  let(:email_body) do
    'save and return email body'
  end
  let(:pages) do
    [
      {
        heading: '',
        answers: [
          {
            field_id: 'save_and_return',
            field_name: 'Save and Return email',
            answer: user_data['email']
          }
        ]
      }
    ]
  end
  let(:pages_payload) do
    [
      {
        heading: '',
        answers: [
          {
            field_id: 'save_and_return',
            field_name: 'Save and Return email',
            answer: 'middle.earth.entertainment@magazine.co.uk'
          }
        ]
      }
    ]
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SAVE_AND_RETURN_EMAIL').and_return(email_body)
  end

  describe '#to_h' do
    let(:service_payload) do
      {
        id: service.service_id,
        slug: service.service_slug,
        name: service.service_name
      }
    end
    let(:actions_payload) do
      [
        {
          kind: 'email',
          to: email_to,
          from: expected_email_from,
          subject: email_subject,
          email_body:,
          include_pdf: false,
          include_attachments: false
        }
      ]
    end

    context 'when all required fields present' do
      it 'sends the service info' do
        expect(save_and_return_payload.to_h[:service]).to eq(service_payload)
      end

      it 'sends actions info' do
        expect(save_and_return_payload.to_h[:actions]).to eq(actions_payload)
      end

      it 'sends pages info' do
        expect(save_and_return_payload.to_h[:pages]).to eq(pages_payload)
      end

      describe '#meta_payload' do
        it 'sends meta info' do
          date = Time.zone.now
          Timecop.freeze(date) do
            expect(save_and_return_payload.to_h[:meta]).to eq(
              { submission_at: date.iso8601 }
            )
          end
        end
      end
    end
  end

  describe '#actions' do
    context "when user['email'] is present" do
      let(:expected_actions) do
        [
          {
            kind: 'email',
            to: email_to,
            from: expected_email_from,
            subject: email_subject,
            email_body:,
            include_pdf: false,
            include_attachments: false
          }
        ]
      end

      before do
        allow(ENV).to receive(:[]).with('SAVE_AND_RETURN_EMAIL').and_return(email_body)
      end

      it 'should return email action' do
        expect(subject.actions).to eq(expected_actions)
      end
    end

    context "when user['email'] is not present" do
      let(:user_data) { { 'id' => 'some-id' } }

      it 'should not send an email' do
        expect(subject.actions).to be_empty
      end
    end
  end
end
