require 'rails_helper'

RSpec.describe Service do
  subject do
    described_class.new(path: '../fb-ioj')
  end

  describe '#pages' do
    it 'returns an array' do
      expect(subject.pages).to be_kind_of(Array)
    end

    it 'contains page instances' do
      expect(subject.pages[0]).to be_kind_of(Page)
    end
  end

  describe '#start_page' do
    it 'returns the start page' do
      expect(subject.start_page.path).to eql("../fb-ioj/metadata/page/page.start.json")
    end
  end
end
