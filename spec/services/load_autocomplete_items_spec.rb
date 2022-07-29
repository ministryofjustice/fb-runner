RSpec.describe LoadAutocompleteItems do
  subject(:load_autocomplete_items) { described_class.new(attributes) }

  describe '#to_h' do
    context 'when there are autocomplete items' do
      let(:autocomplete_items) do
        File.read(
          MetadataPresenter::Engine.root.join('fixtures', 'countries.json')
        )
      end
      let(:attributes) do
        {
          autocomplete_items: autocomplete_items,
          fixture: nil
        }
      end

      it 'returns the autocomplete items' do
        expect(load_autocomplete_items.to_h).to eq(JSON.parse(autocomplete_items))
      end
    end

    context 'when autocomplete items is blank' do
      context 'when fixture is present' do
        let(:attributes) do
          {
            autocomplete_items: nil,
            fixture: 'countries'
          }
        end
        let(:expected_values) do
          {
            '4dc23b9c-9757-4526-813d-b43efbe07dad' =>
            [
              { 'text' => 'Afghanistan', 'value' => 'AF' },
              { 'text' => 'Albania', 'value' => 'AL' },
              { 'text' => 'Australia', 'value' => 'AU' }
            ]
          }
        end

        it 'returns the autocomplete items from fixture' do
          expect(load_autocomplete_items.to_h).to include(expected_values)
        end
      end
    end

    context 'when autocomplete items is invalid' do
      let!(:attributes) do
        {
          autocomplete_items: %({ "foo": ["bar"] }),
          fixture: nil
        }
      end

      it 'raises JSON schema validation error' do
        expect {
          load_autocomplete_items.to_h
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
