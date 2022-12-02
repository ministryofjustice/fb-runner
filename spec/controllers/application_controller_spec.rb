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

  describe '#autocomplete_items' do
    let(:components) { service.find_page_by_url('/countries').components }
    let(:autocomplete_items) do
      expected_items.merge({
        '12346' => [{ 'text': 'cat', 'value': 'dog' }],
        '45679' => [{ 'text': 'red', 'value': 'blue' }],
        '67890' => [{ 'text': 'green', 'value': 'yellow' }]
      })
    end
    let(:expected_items) do
      {
        components.first.uuid => [{ 'text': 'abc', 'value': '123' }]
      }
    end

    context 'when the service has autocomplete items' do
      before do
        allow(Rails.configuration).to receive(:autocomplete_items).and_return(autocomplete_items)
      end

      it 'returns the autocomplete items' do
        expect(controller.autocomplete_items(components)).to eq(expected_items)
      end
    end

    context 'when the service does not have autocomplete items' do
      it 'returns an nil' do
        expect(controller.autocomplete_items(components)).to be_empty
      end
    end
  end

  describe '#update_session_with_reference_number_if_enabled' do
    let(:session) { { 'user_data' => { 'num_number_1' => '42', 'email_email_1' => 'e@mail.com' } } }
    before do
      allow(ENV).to receive(:[])
    end

    context 'reference number is not enabled' do
      before do
        allow(ENV).to receive(:[]).with('REFERENCE_NUMBER').and_return(nil)
      end

      it 'doesn\'t create or update a session key user_data' do
        user_data = controller.update_session_with_reference_number_if_enabled(session)
        expect(user_data.key?('moj_forms_reference_number')).to be_falsey
      end
    end

    context 'when reference number is enabled' do
      before do
        allow(ENV).to receive(:[]).with('REFERENCE_NUMBER').and_return('1')
      end

      it 'create or update a session key user_data' do
        user_data = controller.update_session_with_reference_number_if_enabled(session)
        expect(user_data.key?('moj_forms_reference_number')).to be_truthy
      end
    end
  end
end
