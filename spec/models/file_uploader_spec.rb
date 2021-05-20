RSpec.describe FileUploader do
  subject(:file_uploader) do
    described_class.new(
      session: session,
      page_answers: page_answers,
      component: component
    )
  end
  let(:session) { { session_id: '3337407fcd59870be6f15daccf17d311' } }
  let(:page_answers) do
    double(
      'dog-picture' => {
        'original_filename' => './spec/fixtures/thats-not-a-knife.txt',
        'content_type' => 'text/plain',
        'tempfile' => Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt')
      }
    )
  end
  let(:component) { double(id: 'dog-picture') }

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SERVICE_SECRET').and_return(
      '36a1740b-9d26-4185-a302-5c2ea9b5'
    )
  end

  describe '#upload' do
    context 'when filestore is enabled' do
      let(:filestore_response) do
        {
          'fingerprint' => '28d-3ed12ce99192845d1da98c32797d7c815280db922e006554991332cf2a2dd832',
          'size' => 191317,
          'type' => 'image/png',
          'date' => 1623933256
        }
      end

      before do
        allow(ENV).to receive(:[]).with('FILESTORE_URL').and_return(
          'http://filestore-svc/'
        )
      end

      it 'calls filestore adapter' do
        expect_any_instance_of(Platform::UserFilestoreAdapter).to receive(
          :call
        ).and_return(
          filestore_response
        )
        expect(file_uploader.upload).to eq(
          UploadedFile.new(file: filestore_response, component: component)
        )
      end
    end

    context 'when filestore is not enabled' do
      before do
        allow(ENV).to receive(:[]).with('FILESTORE_URL').and_return(nil)
      end

      context 'when production environment' do
        before do
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        it 'raises exception' do
          expect {
            file_uploader.upload
          }.to raise_error(MissingFilestoreUrlError)
        end
      end

      context 'when not in live environment' do
        before do
          allow(Rails.env).to receive(:production?).and_return(false)
        end

        it 'call offline upload adapter' do
          expect_any_instance_of(OfflineUploadAdapter).to receive(:call)
          file_uploader.upload
        end
      end
    end
  end
end
