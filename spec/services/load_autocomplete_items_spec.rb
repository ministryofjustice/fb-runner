RSpec.describe LoadAutocompleteItems do
  subject(:load_autocomplete_items) { described_class.new(**attributes) }
  let(:service_id) { nil }
  let(:autocomplete_items) { nil }
  let(:fixture) { nil }
  let(:attributes) do
    {
      service_id:,
      autocomplete_items:,
      fixture:
    }
  end

  describe '#to_h' do
    context 'when there is no service id present' do
      context 'when there are autocomplete items' do
        let(:autocomplete_items) do
          File.read(
            MetadataPresenter::Engine.root.join('fixtures', 'countries.json')
          )
        end

        it 'returns the autocomplete items' do
          expect(load_autocomplete_items.to_h).to eq(JSON.parse(autocomplete_items))
        end
      end

      context 'when autocomplete items is blank' do
        context 'when fixture is present' do
          let(:fixture) { 'countries' }
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
        let(:autocomplete_items) { %({ "foo": ["bar"] }) }

        it 'raises JSON schema validation error' do
          expect {
            load_autocomplete_items.to_h
          }.to raise_error(JSON::Schema::ValidationError)
        end
      end
    end

    context 'when there is a service id present' do
      let(:service_id) { SecureRandom.uuid }
      let(:file_body) do
        File.read(
          MetadataPresenter::Engine.root.join('fixtures', 'countries.json')
        )
      end

      before do
        allow_any_instance_of(AwsS3Client).to receive(:get_object)
          .with(load_autocomplete_items.object_key)
          .and_return(file_body)
      end

      it 'should write the service metadata to file' do
        file_path = File.join(LoadAutocompleteItems::SERVICE_METADATA_DIRECTORY, load_autocomplete_items.object_key)
        expect(File).to receive(:write).with(file_path, file_body)
        load_autocomplete_items.to_h
      end

      it 'should return the correct metadata' do
        expect(load_autocomplete_items.to_h).to eq(JSON.parse(file_body))
      end
    end
  end
end
