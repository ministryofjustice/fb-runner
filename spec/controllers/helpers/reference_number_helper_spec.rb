require 'rails_helper'

RSpec.describe ReferenceNumberHelper, type: :helper do
  describe '#generate reference number' do
    let(:forbidden_array) { %w[0 O 1 I] }

    it 'creates a 10 characters reference number' do
      expect(helper.generate_reference_number.gsub('-', '').length).to eq(10)
    end

    it 'should have - after 3rd and 7th characters' do
      expect(helper.generate_reference_number[3]).to eq('-')
      expect(helper.generate_reference_number[8]).to eq('-')
    end

    it 'set 3rd and 7th characters as a number' do
      expect(helper.generate_reference_number[2]).to be_in(ReferenceNumberHelper::RANDOM_SOURCE_SET_2)
      expect(helper.generate_reference_number[7]).to be_in(ReferenceNumberHelper::RANDOM_SOURCE_SET_2)
    end

    it 'doesn\'t contains confusing characters such as 0, O, 1 and I' do
      forbidden_array.each do |char|
        expect(helper.generate_reference_number).not_to include(char)
      end
    end
  end
end
