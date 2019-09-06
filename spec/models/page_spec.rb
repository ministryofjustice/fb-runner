require 'rails_helper'

RSpec.describe Page do
  let(:data) do
    Userdata::Memory.new("session_id")
  end

  let(:service) do
    Service.new(path: '../fb-ioj', config: {}, data: data)
  end

  describe '#start?' do
    context 'when start page' do
      subject do
        service.start_page
      end

      it 'returns true' do
        expect(subject.start?).to be_truthy
      end
    end

    context 'when not start page' do
      subject do
        service.find_page_by_id('page.maat')
      end

      it 'returns false' do
        expect(subject.start?).to be_falsey
      end
    end
  end

  describe '#valid?' do
    context 'when valid' do
      before :each do
        data.merge({'maat' => 'a'})
      end

      after :each do
        Rails.cache.clear
      end

      subject do
        service.find_page_by_id('page.maat')
      end

      it 'returns true' do
        expect(subject.valid?).to be_truthy
      end
    end

    context 'when invalid' do
      subject do
        service.find_page_by_id('page.maat')
      end

      it 'returns true' do
        expect(subject.valid?).to be_falsey
      end
    end
  end
end
