require 'rails_helper'

RSpec.describe Page do
  subject do
    described_class.new(path: '../fb-ioj/metadata/page/page.start.json')
  end

  describe '#start?' do
    context 'when start page' do
      it 'returns true' do
        expect(subject.start?).to be_truthy
      end
    end

    context 'when not start page' do
      subject do
        described_class.new(path: '../fb-ioj/metadata/page/page.summary.json')
      end

      it 'returns false' do
        expect(subject.start?).to be_falsey
      end
    end
  end
end
