RSpec.describe UploadedFile do
  subject(:uploaded_file) do
    described_class.new(
      file: file,
      component: component
    )
  end
  let(:file) { double }
  let(:component) { double }

  describe '#error_name' do
    context 'when object has errors' do
      let(:file) { double(error_name: 'invalid.virus') }

      it 'returns error name' do
        expect(uploaded_file.error_name).to eq('invalid.virus')
      end
    end

    context 'when object is uploaded' do
      it 'returns nil' do
        expect(uploaded_file.error_name).to be_nil
      end
    end
  end
end
