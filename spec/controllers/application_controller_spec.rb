RSpec.describe ApplicationController do
  describe '#upload_adapter' do
    context 'when filestore url is present' do
      before do
        allow(ENV).to receive(:[]).with('USER_FILESTORE_URL').and_return(
          'http://filestore-api-svc/'
        )
      end

      it 'returns UserFilestoreAdapter' do
        expect(controller.upload_adapter).to eq(Platform::UserFilestoreAdapter)
      end
    end

    context 'when filestore url is blank' do
      before do
        allow(ENV).to receive(:[]).with('USER_FILESTORE_URL').and_return(nil)
        allow(Rails.env).to receive(:production?).and_return(production?)
      end

      context 'when production' do
        let(:production?) { true }

        it 'raises missing filestore url error' do
          expect {
            controller.upload_adapter
          }.to raise_error(Platform::MissingFilestoreUrlError)
        end
      end

      context 'when development' do
        let(:production?) { false }

        it 'returns offline adapter' do
          expect(
            controller.upload_adapter
          ).to eq(MetadataPresenter::OfflineUploadAdapter)
        end
      end
    end
  end
end
