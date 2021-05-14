RSpec.describe Platform::UserFilestorePayload do
  subject(:user_filestore_payload) do
    described_class.new(file_details)
  end

  describe '#call' do
    context 'valid payload' do
      let(:expected_payload) do
        {
          "encrypted_user_id_and_token": '12345678901234567890123456789012',
          "file": Base64.strict_encode64("THIS IS A KNIFE!\n"),
          "policy": {
            "max_size": Platform::UserFilestorePayload::MAX_FILE_SIZE,
            "allowed_types": Platform::UserFilestorePayload::ALLOWED_TYPES,
            "expires": Platform::UserFilestorePayload::DEFAULT_EXPIRATION
          }
        }
      end
      let(:file_details) do
        {
          "tempfile" => upload_file,
          "original_filename" => "thats-not-a-knife.txt",
          "content_type" => "plain/txt",
          "headers" => "Content-Type: plain/txt"
        }
      end

      let(:upload_file) do
        Rack::Test::UploadedFile.new(
          "./spec/fixtures/thats-not-a-knife.txt", "plain/txt"
        )
      end

      it 'returns correct payload' do
        expect(user_filestore_payload.call).to eq(expected_payload)
      end
    end
  end
end
