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
      id: 'some-id',
      email: 'middle.earth.entertainment@magazine.co.uk'
    }
  end
  let(:email_to) do
    'middle.earth.entertainment@magazine.co.uk'
  end
  let(:expected_email_from) do
    "Version Fixture <#{default_email_address}>"
  end
  let(:default_email_address) { Platform::SaveAndReturnPayload::DEFAULT_EMAIL_ADDRESS }
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
  let(:expected_email_body) { 'Body - Version Fixture - https://version-fixture.dev.test.form.service.justice.gov.uk/return/some-id' }
  let(:expected_email_subject) { 'Subject - Version Fixture' }
  let(:service_slug) { 'version-fixture' }

  let(:localisations) do
    {
      presenter: {
        save_and_return: {
          confirmation_email: {
            subject: 'Subject - %{service_name}',
            body: 'Body - %{service_name} - %{magic_link}'
          }
        }
      }
    }
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('test')
    allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return('dev')
    allow(ENV).to receive(:[]).with('SERVICE_SLUG').and_return(service_slug)
  end

  # Predictable locales
  around(:each) do |example|
    I18n.backend.store_translations(:en, localisations)
    I18n.with_locale(:en) { example.run }
  end

  describe '#to_h' do
    let(:service_payload) do
      {
        id: service.service_id,
        slug: ENV['SERVICE_SLUG'],
        name: service.service_name
      }
    end
    let(:actions_payload) do
      [
        {
          kind: 'email',
          to: email_to,
          from: expected_email_from,
          subject: expected_email_subject,
          email_body: expected_email_body,
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
            subject: expected_email_subject,
            email_body: expected_email_body,
            include_pdf: false,
            include_attachments: false
          }
        ]
      end

      before do
        allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('test')
        allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return('dev')
      end

      context 'when deployment environment is test-dev' do
        it 'should return email action' do
          expect(subject.actions).to eq(expected_actions)
        end
      end

      context 'when deployment environment is test-production' do
        let(:expected_email_body) { 'Body - Version Fixture - https://version-fixture.test.form.service.justice.gov.uk/return/some-id' }

        before do
          allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('test')
          allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return('production')
        end

        it 'should return email action' do
          expect(subject.actions).to eq(expected_actions)
        end
      end

      context 'when deployment environment is live-dev' do
        let(:expected_email_body) { 'Body - Version Fixture - https://version-fixture.dev.form.service.justice.gov.uk/return/some-id' }

        before do
          allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('live')
          allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return('dev')
        end

        it 'should return email action' do
          expect(subject.actions).to eq(expected_actions)
        end
      end

      context 'when deployment environment is live-production' do
        let(:expected_email_body) { 'Body - Version Fixture - https://version-fixture.form.service.justice.gov.uk/return/some-id' }

        before do
          allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('live')
          allow(ENV).to receive(:[]).with('DEPLOYMENT_ENV').and_return('production')
        end

        it 'should return email action' do
          expect(subject.actions).to eq(expected_actions)
        end
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
