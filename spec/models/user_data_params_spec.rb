RSpec.describe UserDataParams do
  subject(:user_data_params) do
    described_class.new(page_answers)
  end
  let(:page_answers) do
    MetadataPresenter::PageAnswers.new(page, answers)
  end

  describe '#answers' do
    context 'when page has uploaded files' do
      let(:page) { service.find_page_by_url('dog-picture') }
      let(:file_details) do
        Rack::Test::UploadedFile.new(
          './spec/fixtures/thats-not-a-knife.txt',
          'plain/txt'
        )
      end
      let(:answers) do
        {
          'dog-picture_upload_1' => file_details
        }
      end
      let(:file) do
        {
          'fingerprint' => '28d-6dbfe5a3fff4a67260e7057e49b13ae0794598a949907a',
          'size' => 1_392_565,
          'type' => 'plain/txt',
          'date' => 1_624_540_833
        }
      end
      let(:uploaded_files) do
        [
          MetadataPresenter::UploadedFile.new(
            file:,
            component: page.components.first
          )
        ]
      end

      before do
        allow(page_answers).to receive(:uploaded_files).and_return(uploaded_files)
      end

      it 'returns the file information' do
        expect(user_data_params.answers).to eq(
          {
            'dog-picture_upload_1' => {
              'original_filename' => 'thats-not-a-knife.txt',
              'content_type' => 'plain/txt',
              'tempfile' => file_details.tempfile.path.to_s
            }.merge(file)
          }
        )
      end
    end

    context 'page with checkbox components' do
      let(:page) { service.find_page_by_url('burgers') }

      context 'when optional' do
        let(:answers) { {} }
        let(:expected_answers) { { 'burgers_checkboxes_1' => [] } }

        it 'should set an empty array for unanswered optional checkboxes' do
          expect(user_data_params.answers).to eq(expected_answers)
        end
      end
    end

    context 'when other answers' do
      let(:page) { service.find_page_by_url('name') }
      let(:answers) { { 'name_text_1' => 'John Wick' } }

      it 'returns the answers' do
        expect(user_data_params.answers).to eq(answers)
      end
    end
  end
end
