RSpec.describe Platform::SubmitterPayload do
  let(:session) { { session_id: '1234' } }
  subject(:submitter_payload) do
    described_class.new(
      service: service,
      user_data: user_data,
      session: session
    )
  end

  def content_components
    service.pages.map(&:components).compact.flatten.select(&:content?)
  end

  def content_components_text
    content_components.map(&:html)
  end

  let(:user_data) do
    {
      'name_text_1' => 'Legolas',
      'email-address_text_1' => 'legolas@middle.earth.com',
      'parent-name_text_1' => 'Thranduil',
      'your-age_number_1' => '2931',
      'family-hobbies_textarea_1' => 'Archery',
      'do-you-like-star-wars_radios_1' => 'Only on weekends',
      'holiday_date_1(3i)' => '30',
      'holiday_date_1(2i)' => '12',
      'holiday_date_1(1i)' => '2020',
      'burgers_checkboxes_1' => ['Beef, cheese, tomato', 'Chicken, cheese, tomato'],
      'star-wars-knowledge_text_1' => 'Max Rebo Band',
      'star-wars-knowledge_radios_1' => 'Din Jarrin',
      'dog-picture_upload_1' => {
        'original_filename' => 'basset-hound.jpg',
        'content_type' => 'image/jpg',
        'tempfile' => upload_file.path,
        'fingerprint' => '28d-6dbfe5a3fff4a67260e7057e49b13ae0794598a949907a',
        'size' => 1_392_565,
        'type' => 'image/jpg',
        'date' => 1_624_540_833
      }
    }
  end
  let(:upload_file) do
    Rack::Test::UploadedFile.new(
      './spec/fixtures/basset-hound.jpg', 'image/jpg'
    )
  end
  let(:pdf_heading) do
    'Middle Earth characters'
  end
  let(:pdf_subheading) do
    nil
  end
  let(:email_to) do
    'middle.earth.entertainment@magazine.co.uk'
  end
  let(:email_from) do
    'MoJ forms <moj-online@digital.justice.gov.uk>'
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
        heading: '',
        answers: [
          {
            field_id: 'name_text_1',
            field_name: 'Full name',
            answer: 'Legolas'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'email-address_text_1',
            field_name: 'Email address',
            answer: 'legolas@middle.earth.com'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'parent-name_text_1',
            field_name: 'Parent name',
            answer: 'Thranduil'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'your-age_number_1',
            field_name: 'Your age',
            answer: '2931'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'family-hobbies_textarea_1',
            field_name: 'Family Hobbies',
            answer: 'Archery'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'do-you-like-star-wars_radios_1',
            field_name: 'Do you like Star Wars?',
            answer: 'Only on weekends'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'holiday_date_1',
            field_name: 'What is the day that you like to take holidays?',
            answer: '30 December 2020'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            field_id: 'burgers_checkboxes_1',
            field_name: 'What would you like on your burger?',
            answer: ['Beef, cheese, tomato', 'Chicken, cheese, tomato']
          }
        ]
      },
      {
        heading: 'How well do you know Star Wars?',
        answers: [
          {
            field_id: 'star-wars-knowledge_text_1',
            field_name: "What was the name of the band playing in Jabba's palace?",
            answer: 'Max Rebo Band'
          },
          {
            field_id: 'star-wars-knowledge_radios_1',
            field_name: "What is The Mandalorian's real name?",
            answer: 'Din Jarrin'
          }
        ]
      },
      {
        heading: '',
        answers: [
          {
            answer: 'basset-hound.jpg',
            field_id: 'dog-picture_upload_1',
            field_name: 'Upload your best dog photo'
          }
        ]
      }
    ]
  end

  describe '#to_h' do
    let(:service_payload) do
      {
        id: service.service_id,
        slug: 'version-fixture',
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

    context 'when optional fields' do
      subject(:submitter_payload) do
        described_class.new(
          service: service,
          user_data: user_data.merge(
            {
              'holiday_date_1(3i)' => '',
              'holiday_date_1(2i)' => '',
              'holiday_date_1(1i)' => '',
              'burgers_checkboxes_1' => nil
            }
          ),
          session: session
        )
      end
      let(:answers) do
        submitter_payload.to_h[:pages].map { |page| page[:answers] }
      end
      let(:date_answer) do
        answers.flatten.find { |answer| answer[:field_id] == 'holiday_date_1' }
      end

      it 'sends pages info with dates blank' do
        expect(
          date_answer
        ).to eq({
          field_id: 'holiday_date_1',
          field_name: 'What is the day that you like to take holidays?',
          answer: ''
        })
      end

      let(:checkbox_answer) do
        answers.flatten.find { |answer| answer[:field_id] == 'burgers_checkboxes_1' }
      end

      it 'sends pages with blank checkboxes' do
        expect(
          checkbox_answer
        ).to eq({
          field_id: 'burgers_checkboxes_1',
          field_name: 'What would you like on your burger?',
          answer: []
        })
      end
    end

    context 'when all required fields present' do
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
          expect(submitter_payload.to_h[:meta][:pdf_subheading]).to eq('')
        end

        it 'sends meta info' do
          expect(submitter_payload.to_h[:meta]).to eq(
            {
              pdf_heading: pdf_heading,
              pdf_subheading: ''
            }
          )
        end
      end

      it 'does not send any content components text in the payload' do
        answers = submitter_payload.to_h[:pages].map { |page_answers|
          page_answers[:answers].map { |answers| answers[:answer] }
        }.flatten

        expect(answers & content_components_text).to be_empty
      end
    end

    context 'with uploaded files' do
      before do
        allow(ENV).to receive(:[]).with('USER_FILESTORE_URL').and_return('https://www.yeah-baby.com')
        allow(ENV).to receive(:[]).with('SERVICE_SLUG').and_return('groovy')
      end

      context 'with required file upload questions' do
        it 'sends the correct attachments object in the payload' do
          expect(submitter_payload.to_h[:attachments]).to eq(
            [
              {
                url: 'https://www.yeah-baby.com/service/groovy/user/1234/28d-6dbfe5a3fff4a67260e7057e49b13ae0794598a949907a',
                filename: 'basset-hound.jpg',
                mimetype: 'image/jpg'
              }
            ]
          )
        end
      end

      context 'with optional file upload questions ie no answer in user data' do
        let(:user_data) { {} }

        it 'sends an empty array in the attachments' do
          expect(submitter_payload.to_h[:attachments]).to eq([])
        end
      end
    end
  end
end
