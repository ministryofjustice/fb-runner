RSpec.describe Platform::UserFilestorePayload do
  subject(:user_filestore_payload) do
    described_class.new(
      session:,
      file_details:,
      service_secret:,
      allowed_file_types: allowed_types
    )
  end
  let(:session) do
    {
      user_id: '04cf476c2dd02e01304d7ab321764096',
      user_token: '162738e2772348798c657c64c226042e'
    }
  end
  let(:service_secret) do
    '499bed391d8d3c937421c4254a0d2b0e'
  end

  describe '#call' do
    context 'valid payload' do
      let(:expected_payload) do
        {
          'encrypted_user_id_and_token': '/7danQNZrt06+SZlQUOjsxcRvy9wiuW6Y9lxQg9EF4s8TaXc/Ez/UK2LZkKQ/NR0T8WJJTJB3HKlLj3V2F5iWQ==',
          'file': Base64.strict_encode64("THIS IS A KNIFE!\n"),
          'policy': {
            'max_size': Platform::UserFilestorePayload::MAX_FILE_SIZE,
            'allowed_types': expected_allowed_types,
            'expires': Platform::UserFilestorePayload::DEFAULT_EXPIRATION
          }
        }
      end
      let(:file_details) do
        {
          'tempfile' => upload_file,
          'original_filename' => 'thats-not-a-knife.txt',
          'content_type' => 'plain/txt',
          'headers' => 'Content-Type: plain/txt'
        }
      end

      let(:upload_file) do
        Rack::Test::UploadedFile.new(
          './spec/fixtures/thats-not-a-knife.txt', 'plain/txt'
        )
      end

      context 'when there are allowed types set in the upload component' do
        let(:allowed_types) do
          service.find_page_by_url('dog-picture').components.first.validation['accept']
        end
        let(:expected_allowed_types) do
          allowed_types
        end

        it 'adds the allowed filestypes from the component to the payload' do
          expect(user_filestore_payload.call).to eq(expected_payload)
        end
      end

      context 'when there are no allowed types set in the upload component' do
        let(:allowed_types) { nil }
        let(:expected_allowed_types) do
          Platform::UserFilestorePayload::ALLOWED_TYPES
        end

        it 'adds the default allowed filetypes to the payload' do
          expect(user_filestore_payload.call).to eq(expected_payload)
        end
      end
    end
  end
end
