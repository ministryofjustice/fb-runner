RSpec.describe Platform::SubmitterPayload do
  subject(:submitter_payload) do
    described_class.new(service: service, user_data: user_data)
  end

  let(:user_data) do
    {
      'name_text_1' => 'Legolas',
      'email-address_email_1' => 'legolas@middle.earth.com',
      'parent-name_text_1' => 'Thranduil',
      'your-age_number_1' => '2931',
      'family-hobbies_text_1' => 'Archery',
      'do-you-like-star-wars_radios_1' => 'Only on weekends',
      'holiday_date_1(3i)' => '30',
      'holiday_date_1(2i)' => '12',
      'holiday_date_1(1i)' => '2020',
      'burgers_checkboxes_1' => ['Beef, cheese, tomato', 'Chicken, cheese, tomato'],
      'star-wars-knowledge_text_1' => "Max Rebo Band",
      'star-wars-knowledge_radios_1' => "Din Jarrin"
    }
  end
  let(:pdf_heading) do
    "Middle Earth characters"
  end
  let(:pdf_subheading) do
    nil
  end
  let(:email_to) do
    "middle.earth.entertainment@magazine.co.uk"
  end
  let(:email_from) do
    "MoJ forms <moj-online@digital.justice.gov.uk>"
  end
  let(:email_subject) do
    'All info about middle earth characters'
  end
  let(:email_body) do
    'Please find attached Elfs info!'
  end

  let(:pages_payload) do
    [
      {
        heading: "",
        answers: [
          {
            field_id: "name_text_1",
            field_name: "Full name",
            answer: "Legolas"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "email-address_email_1",
            field_name: "Your email address",
            answer: "legolas@middle.earth.com"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "parent-name_text_1",
            field_name: "Parent name",
            answer: "Thranduil"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "your-age_number_1",
            field_name: "Your age",
            answer: "2931"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "family-hobbies_text_1",
            field_name: "Your family hobbies",
            answer: "Archery"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "do-you-like-star-wars_radios_1",
            field_name: "Do you like Star Wars?",
            answer: "Only on weekends"
          }
        ]
      },
      {
        heading: "",
        answers: [
          {
            field_id: "holiday_date_1",
            field_name: "What is the day that you like to take holidays?",
            answer: "30 December 2020"
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: "burgers_checkboxes_1",
            field_name: "What would you like on your burger?",
            answer: ['Beef, cheese, tomato', 'Chicken, cheese, tomato']
          }
        ]
      },
      {
        heading: 'How well do you know Star Wars?',
        answers: [
          {
            field_id: "star-wars-knowledge_text_1",
            field_name: "What was the name of the band playing in Jabba's palace?",
            answer: "Max Rebo Band"
          },
          {
            field_id: "star-wars-knowledge_radios_1",
            field_name: "What is The Mandalorian's real name?",
            answer: "Din Jarrin"
          }
        ]
      }
    ]
  end

  describe '#to_h' do
    let(:service_payload) do
      {
        id: service.service_id,
        slug: 'service-name',
        name: service.service_name
      }
    end
    let(:actions_payload) do
      [
        {
          kind: 'email',
          to: email_to,
          from: email_from,
          subject: email_subject,
          email_body: email_body,
          include_pdf: true
        }
      ]
    end

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_HEADING')
        .and_return(pdf_heading)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_SUBHEADING')
        .and_return(pdf_subheading)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT')
        .and_return(email_to)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_FROM')
        .and_return(email_from)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_SUBJECT')
        .and_return(email_subject)
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_BODY')
        .and_return(email_body)
    end

    it 'sends the service info' do
      expect(submitter_payload.to_h[:service]).to eq(service_payload)
    end

    it 'sends actions info' do
      expect(submitter_payload.to_h[:actions]).to eq(actions_payload)
    end

    it 'sends pages info' do
      expect(submitter_payload.to_h[:pages]).to eq(pages_payload)
    end

    describe '#meta_payload' do
      it 'SERVICE_EMAIL_PDF_SUBHEADING defaults to an empty string' do
        expect(submitter_payload.to_h[:meta][:pdf_subheading]).to eq("")
      end

      it 'sends meta info' do
        expect(submitter_payload.to_h[:meta]).to eq(
          {
            :pdf_heading=>pdf_heading,
            :pdf_subheading=>""
            }
          )
      end
    end
  end
end
