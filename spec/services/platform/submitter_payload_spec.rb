RSpec.describe Platform::SubmitterPayload do
  let(:session) { { user_id: 'user-id-5b10c947cf32bd0558318e77eebc0995' } }
  subject(:submitter_payload) do
    described_class.new(
      service:,
      user_data:,
      session:
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
      'email-address_email_1' => 'legolas@middle.earth.com',
      'parent-name_text_1' => 'Thranduil',
      'your-age_number_1' => '2931',
      'family-hobbies_textarea_1' => textarea_answer,
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
      },
      'countries_autocomplete_1' => '{"text":"Malawi","value":"MW"}'
    }
  end
  let(:textarea_answer) do
    "        Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro.\nDe carne lumbering animata corpora quaeritis. Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead.\r\n\r\n       "
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
  let(:email_component_id) { 'email-address_email_1' }
  let(:confirmation_email_subject) do
    'Delicious dinosaurs'
  end
  let(:confirmation_email_body) do
    'Triceramisu, Falafel-raptor, Diplodonuts, Berry-dactyl'
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
            field_id: 'email-address_email_1',
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
            answer: expected_textarea
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
            answer: 'Beef, cheese, tomato; Chicken, cheese, tomato'
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
      },
      {
        heading: '',
        answers: [
          {
            answer: 'MW',
            field_id: 'countries_autocomplete_1',
            field_name: 'Countries'
          }
        ]
      }
    ]
  end
  let(:expected_textarea) do
    "Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro.\nDe carne lumbering animata corpora quaeritis. Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead."
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SERVICE_EMAIL_FROM').and_return(email_from)
    allow(ENV).to receive(:[]).with('SERVICE_EMAIL_SUBJECT').and_return(email_subject)
    allow(ENV).to receive(:[]).with('SERVICE_EMAIL_BODY').and_return(email_body)
    allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_SUBJECT').and_return(confirmation_email_subject)
    allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_BODY').and_return(confirmation_email_body)
    allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_HEADING').and_return(pdf_heading)
    allow(ENV).to receive(:[]).with('SERVICE_EMAIL_PDF_SUBHEADING').and_return(pdf_subheading)
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
          from: email_from,
          subject: email_subject,
          email_body:,
          include_pdf: true,
          include_attachments: true
        },
        {
          kind: 'csv',
          to: email_to,
          from: email_from,
          subject: "CSV - #{email_subject}",
          email_body: '',
          include_pdf: false,
          include_attachments: true
        },
        {
          kind: 'email',
          to: user_data[email_component_id],
          from: email_from,
          subject: confirmation_email_subject,
          email_body: confirmation_email_body,
          include_pdf: true,
          include_attachments: true
        }
      ]
    end

    before do
      allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT').and_return(email_to)
      allow(ENV).to receive(:[]).with('SERVICE_CSV_OUTPUT').and_return('true')
      allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(email_component_id)
    end

    context 'when branching' do
      let(:service_metadata) { metadata_fixture(:branching) }
      let(:user_data) do
        {
          'name_text_1' => 'Thor',
          'do-you-like-star-wars_radios_1' => 'Hell no!',
          'favourite-fruit_radios_1' => 'Apples',
          'apple-juice_radios_1' => 'Yes',
          # Below, this answer will be ignored because
          # the user's favourite fruit is Apples
          'orange-juice_radios_1' => 'Yes',
          'favourite-band_radios_1' => 'Beatles',
          'music-app_radios_1' => 'iTunes',
          'best-formbuilder_radios_1' => 'Others',
          'burgers_checkboxes_1' => ['Mozzarella, cheddar, feta'],
          'marvel-series_radios_1' => 'Loki',
          'best-arnold-quote_checkboxes_1' => [
            'You are not you. You are me',
            'Get to the chopper',
            'You have been terminated'
          ],
          'which-formbuilder_text_1' => 'MoJ again!'
        }
      end
      let(:pages_payload) do
        [
          {
            heading: '',
            answers: [{ field_id: 'name_text_1', field_name: 'Full name', answer: 'Thor' }]
          },
          { heading: '',
            answers: [{ field_id: 'do-you-like-star-wars_radios_1',
                        field_name: 'Do you like Star Wars?',
                        answer: 'Hell no!' }] },
          { heading: '',
            answers: [{ field_id: 'favourite-fruit_radios_1',
                        field_name: 'What is your favourite fruit?',
                        answer: 'Apples' }] },
          { heading: '',
            answers: [{ field_id: 'apple-juice_radios_1',
                        field_name: 'Do you like apple juice?',
                        answer: 'Yes' }] },
          { heading: '',
            answers: [{ field_id: 'favourite-band_radios_1',
                        field_name: 'What is your favourite band?',
                        answer: 'Beatles' }] },
          { heading: '',
            answers: [{ field_id: 'music-app_radios_1',
                        field_name: 'Which app do you use to listen music?',
                        answer: 'iTunes' }] },
          { heading: '',
            answers: [{ field_id: 'best-formbuilder_radios_1',
                        field_name: 'What is the best form builder?',
                        answer: 'Others' }] },
          { heading: '',
            answers: [{ field_id: 'which-formbuilder_text_1',
                        field_name: 'Which Formbuilder is the best?',
                        answer: 'MoJ again!' }] },
          { heading: '',
            answers: [{ field_id: 'burgers_checkboxes_1',
                        field_name: 'What would you like on your burger?',
                        answer: 'Mozzarella, cheddar, feta' }] },
          { heading: '',
            answers: [{ field_id: 'marvel-series_radios_1',
                        field_name: 'What is the best marvel series?',
                        answer: 'Loki' }] },
          { heading: '',
            answers: [
              {
                field_id: 'best-arnold-quote_checkboxes_1',
                field_name: 'Select all Arnold Schwarzenegger quotes',
                answer: 'You are not you. You are me; Get to the chopper; You have been terminated'
              }
            ] }
        ]
      end

      it 'sends right pages and ignores answers based on branching' do
        expect(submitter_payload.to_h[:pages]).to eq(pages_payload)
      end
    end

    context 'when optional fields' do
      subject(:submitter_payload) do
        described_class.new(
          service:,
          user_data: user_data.merge(
            {
              'holiday_date_1(3i)' => '',
              'holiday_date_1(2i)' => '',
              'holiday_date_1(1i)' => '',
              'burgers_checkboxes_1' => nil,
              'dog-picture_upload_1' => {}
            }
          ),
          session:
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
          answer: ''
        })
      end

      let(:upload_answer) do
        answers.flatten.find { |answer| answer[:field_id] == 'dog-picture_upload_1' }
      end

      it 'sends an empty string if file uploads have no uploaded file' do
        expect(
          upload_answer
        ).to eq({
          field_id: 'dog-picture_upload_1',
          field_name: 'Upload your best dog photo',
          answer: ''
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
          date = Time.zone.now
          Timecop.freeze(date) do
            expect(submitter_payload.to_h[:meta]).to eq(
              {
                pdf_heading:,
                pdf_subheading: '',
                submission_at: date.iso8601
              }
            )
          end
        end

        context 'when reference number is not present' do
          it 'does not include the reference number' do
            expect(submitter_payload.to_h[:meta].key?(:reference_number)).to be_falsey
          end
        end

        context 'when reference number is present' do
          let(:reference_number) { 'some-reference-number' }
          let(:user_data) { { 'moj_forms_reference_number' => reference_number } }

          it 'adds the reference number attribute and value' do
            meta_payload = submitter_payload.to_h[:meta]
            expect(meta_payload[:reference_number]).to eq(reference_number)
          end
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
                url: 'https://www.yeah-baby.com/service/groovy/user/user-id-5b10c947cf32bd0558318e77eebc0995/28d-6dbfe5a3fff4a67260e7057e49b13ae0794598a949907a',
                filename: 'basset-hound.jpg',
                mimetype: 'image/jpg'
              }
            ]
          )
        end
      end

      context 'with optional file upload questions ie no answer in user data' do
        let(:user_data) { { 'dog-picture_upload_1' => {} } }

        it 'sends an empty array in the attachments' do
          expect(submitter_payload.to_h[:attachments]).to eq([])
        end
      end
    end
  end

  describe '#actions' do
    context 'when email, csv outputs and confirmation email are required' do
      let(:expected_actions) do
        [
          {
            kind: 'email',
            to: email_to,
            from: email_from,
            subject: email_subject,
            email_body:,
            include_pdf: true,
            include_attachments: true
          },
          {
            kind: 'csv',
            to: email_to,
            from: email_from,
            subject: "CSV - #{email_subject}",
            email_body: '',
            include_pdf: false,
            include_attachments: true
          },
          {
            kind: 'email',
            to: user_data[email_component_id],
            from: email_from,
            subject: confirmation_email_subject,
            email_body: confirmation_email_body,
            include_pdf: true,
            include_attachments: true
          }
        ]
      end

      before do
        allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT').and_return(email_to)
        allow(ENV).to receive(:[]).with('SERVICE_CSV_OUTPUT').and_return('true')
        allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(email_component_id)
      end

      it 'should return three actions' do
        expect(subject.actions).to eq(expected_actions)
      end
    end

    context 'when email output only is required' do
      let(:expected_actions) do
        [
          {
            kind: 'email',
            to: email_to,
            from: email_from,
            subject: email_subject,
            email_body:,
            include_pdf: true,
            include_attachments: true
          }
        ]
      end
      before do
        allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT').and_return(email_to)
      end

      it 'should return just the email action' do
        expect(subject.actions).to eq(expected_actions)
      end
    end

    context 'when confirmation email output only is required' do
      let(:expected_actions) do
        [
          {
            kind: 'email',
            to: user_data[email_component_id],
            from: email_from,
            subject: confirmation_email_subject,
            email_body: confirmation_email_body,
            include_pdf: true,
            include_attachments: true
          }
        ]
      end

      before do
        allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(email_component_id)
      end

      context 'and the user has submitted an email' do
        it 'should return just the confirmation email action' do
          expect(subject.actions).to eq(expected_actions)
        end
      end

      context 'and the user has not submitted an email' do
        let(:user_data) do
          {
            'name_text_1' => 'Legolas',
            'email-address_email_1' => '',
            'countries_autocomplete_1' => '{"text":"Malawi","value":"MW"}'
          }
        end

        it 'should not return the confirmation email action' do
          expect(subject.actions).to eq([])
        end
      end
    end

    context 'when no outputs are required' do
      it 'should return an empty array' do
        expect(subject.actions).to be_empty
      end
    end

    context 'when email output and confirmation email to address are the same' do
      let(:email_to) do
        'legolas@middle.earth.com'
      end
      let(:confirmation_to) do
        'legolas+confirmation@middle.earth.com'
      end
      let(:expected_actions) do
        [
          {
            kind: 'email',
            to: email_to,
            from: email_from,
            subject: email_subject,
            email_body:,
            include_pdf: true,
            include_attachments: true
          },
          {
            kind: 'email',
            to: confirmation_to,
            from: email_from,
            subject: confirmation_email_subject,
            email_body: confirmation_email_body,
            include_pdf: true,
            include_attachments: true
          }
        ]
      end

      before do
        allow(ENV).to receive(:[]).with('SERVICE_EMAIL_OUTPUT').and_return(email_to)
        allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(email_component_id)
      end

      it 'should return confirmation email to address with "+confirmation@"' do
        expect(subject.actions).to eq(expected_actions)
      end
    end
  end

  describe '#concatenation_with_reference_number' do
    let(:dummy_reference) { '1234-ABC-567' }
    let(:text_without_reference_number) { 'email subject or email body.' }
    let(:text_with_reference_number) { 'email subject or email body. Your reference number is {{reference_number}}' }

    before do
      allow(user_data).to receive(:[]).with('moj_forms_reference_number').and_return(dummy_reference)
    end

    context 'reference is not enabled' do
      it 'should return empty string' do
        expect(submitter_payload.concatenation_with_reference_number(text_without_reference_number))
        .to eq(text_without_reference_number)
      end
    end

    context 'reference number is enabled' do
      before do
        allow(ENV).to receive(:[]).with('REFERENCE_NUMBER').and_return('1')
      end

      it 'should return a reference number' do
        expect(submitter_payload.concatenation_with_reference_number(text_with_reference_number))
        .to eq(text_with_reference_number.gsub('{{reference_number}}', dummy_reference))
      end
    end
  end

  context 'payment links' do
    let(:payment_link) { 'http://www.mustafa.com/vader-tax?reference=' }
    let(:dummy_reference) { '1234-ABC-567' }
    let(:confirmation_email_body) do
      'some email body {{payment_link}}'
    end
    let(:expected_confirmation_email_body) do
      "some email body #{payment_link}#{dummy_reference}"
    end
    let(:expected_actions) do
      [
        {
          kind: 'email',
          to: user_data[email_component_id],
          from: email_from,
          subject: confirmation_email_subject,
          email_body: expected_confirmation_email_body,
          include_pdf: true,
          include_attachments: true
        }
      ]
    end
    let(:user_data) do
      {
        'moj_forms_reference_number' => dummy_reference,
        'email-address_email_1' => 'legolas@middle.earth.com'
      }
    end

    before do
      allow(ENV).to receive(:[]).with('PAYMENT_LINK').and_return(payment_link)
      allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(email_component_id)
    end

    it 'should insert the payment link' do
      expect(submitter_payload.to_h[:actions]).to eq(expected_actions)
    end
  end
end
