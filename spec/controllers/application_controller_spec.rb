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

    describe '#save_and_return_enabled?' do
      context 'when save and return is enabled' do
        before do
          allow(ENV).to receive(:[]).with('SAVE_AND_RETURN').and_return('enabled')
        end

        it 'returns true' do
          expect(controller.save_and_return_enabled?).to eq(true)
        end
      end

      context 'when save and return is disabled' do
        it 'returns false' do
          expect(controller.save_and_return_enabled?).to eq(false)
        end
      end
    end

    describe '#save_form_progress' do
      let(:save_progress) { double }

      it 'calls save progress' do
        expect(SavedProgress).to receive(:new).and_return(save_progress)
        expect(save_progress).to receive(:save_progress)
        controller.save_form_progress
      end
    end

    describe '#get_saved_progress' do
      let(:save_progress) { double }
      let(:uuid) { SecureRandom.uuid }

      it 'calls get_saved_progress' do
        expect(SavedProgress).to receive(:new).and_return(save_progress)
        expect(save_progress).to receive(:get_saved_progress).with(uuid)
        controller.get_saved_progress(uuid)
      end
    end

    describe '#increment_record_counter' do
      let(:save_progress) { double }
      let(:uuid) { SecureRandom.uuid }

      it 'calls increment_record_counter' do
        expect(SavedProgress).to receive(:new).and_return(save_progress)
        expect(save_progress).to receive(:increment_record_counter).with(uuid)
        controller.increment_record_counter(uuid)
      end
    end

    describe '#invalidate_record' do
      let(:save_progress) { double }
      let(:uuid) { SecureRandom.uuid }

      it 'calls invalidate_record' do
        expect(SavedProgress).to receive(:new).and_return(save_progress)
        expect(save_progress).to receive(:invalidate).with(uuid)
        controller.invalidate_record(uuid)
      end
    end

    describe '#service_slug_config' do
      context 'when service slug is present' do
        before do
          allow(ENV).to receive(:[]).with('SERVICE_SLUG').and_return(service_slug)
        end
        let(:service_slug) { 'i-am-a-slug' }

        it 'returns the service slug' do
          expect(controller.service_slug_config).to eq(service_slug)
        end
      end

      context 'when service slug is not present' do
        it 'returns nil' do
          expect(controller.service_slug_config).to be_nil
        end
      end
    end
  end

  describe 'helpers' do
    let(:session) { { 'user_data' => { 'moj_forms_reference_number' => '123' } } }
    let(:payment_link) { 'hello.payment.com' }

    before do
      allow(ENV).to receive(:[])
      allow(controller).to receive(:load_user_data).and_return(session['user_data'])
      allow(controller).to receive(:allowed_page?).and_return(true)
    end

    it 'should show_reference_number' do
      expect(controller.show_reference_number).to eq('123')
    end

    it 'should return payment_link_url' do
      allow(ENV).to receive(:[]).with('PAYMENT_LINK').and_return(payment_link)
      expect(controller.payment_link_url).to eq("#{payment_link}123")
    end

    it 'responds to in_progress?' do
      expect(controller.in_progress?).to eq(true)
    end

    it 'is not in preview mode' do
      expect(controller.editor_preview?).to eq(false)
    end

    context 'external start page' do
      context 'is not using external start page' do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with('EXTERNAL_START_PAGE_URL').and_return('')
        end

        it 'returns false' do
          expect(controller.use_external_start_page?).to eq(false)
        end
      end

      context 'is using external start page' do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with('EXTERNAL_START_PAGE_URL').and_return('external_url.com')
        end

        it 'returns true' do
          expect(controller.use_external_start_page?).to eq(true)
        end
      end
    end

    context 'external start page url' do
      before do
        allow(ENV).to receive(:[])
      end

      it 'is blank if not set' do
        allow(ENV).to receive(:[]).with('EXTERNAL_START_PAGE_URL').and_return('')

        expect(controller.external_start_page_url).to eq('')
      end

      it 'is prepended https if not set' do
        allow(ENV).to receive(:[]).with('EXTERNAL_START_PAGE_URL').and_return('example.com')

        expect(controller.external_start_page_url).to eq('https://example.com')
      end

      it 'is returned set' do
        allow(ENV).to receive(:[]).with('EXTERNAL_START_PAGE_URL').and_return('https://my-example.com')

        expect(controller.external_start_page_url).to eq('https://my-example.com')
      end
    end

    context 'first page?' do
      before do
        controller.instance_eval { @page = OpenStruct.new(url: '/page1') }
      end

      it 'is not page 1' do
        expect(controller.first_page?).to eq(false)
      end

      context 'it is page 1' do
        before do
          controller.instance_eval { @page = OpenStruct.new(url: 'name') }
        end
  
        it 'is page 1' do
          expect(controller.first_page?).to eq(true)
        end
      end
    end
  end

  describe '#confirmation_email' do
    before do
      allow(ENV).to receive(:[])
    end

    context 'when confirmation email is not enabled' do
      before do
        allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return(nil)
      end

      it 'confirmation_email_enabled? will return false' do
        expect(controller.confirmation_email_enabled?).to be_falsey
      end

      it 'confirmation email is nil' do
        expect(controller.confirmation_email).to be_nil
      end
    end

    context 'when confirmation email is enabled' do
      let(:session) { { 'user_data' => { 'email_email_1' => 'e@mail.com' } } }

      before do
        allow(ENV).to receive(:[]).with('CONFIRMATION_EMAIL_COMPONENT_ID').and_return('email_email_1')
        allow(controller).to receive(:load_user_data).and_return(session['user_data'])
      end

      it 'confirmation_email_enabled? will return true' do
        expect(controller.confirmation_email_enabled?).to be_truthy
      end

      it 'confirmation email is being retrieved from the user data' do
        expect(controller.confirmation_email).to eq('e@mail.com')
      end
    end
  end
end
