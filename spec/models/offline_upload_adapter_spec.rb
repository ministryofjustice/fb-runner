RSpec.describe OfflineUploadAdapter do
  describe '#call' do
    it 'returns an empty hash' do
      expect(subject.call).to eq({})
    end
  end
end
