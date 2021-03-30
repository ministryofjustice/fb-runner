RSpec.describe LoadServiceMetadata do
  subject(:load_service_metadata) { described_class.new(attributes) }

  describe '#to_h' do
    context 'when service metadata is present' do
      let(:service_metadata) do
        File.read(
          MetadataPresenter::Engine.root.join('fixtures', 'service.json')
        )
      end
      let(:attributes) do
        {
          service_metadata: service_metadata,
          fixture: nil,
          asset_precompile: nil
        }
      end

      it 'returns the service metadata' do
        expect(load_service_metadata.to_h).to eq(JSON.parse(service_metadata))
      end
    end

    context 'when service metadata is blank' do
      context 'when fixture is present' do
        let(:attributes) do
          {
            service_metadata: nil,
            fixture: 'version',
            asset_precompile: nil
          }
        end

        it 'returns the service metadata from fixture' do
          expect(load_service_metadata.to_h).to include(
            'service_name' => 'Service name'
          )
        end
      end

      context 'when fixture is not present' do
        context 'when asset pipeline is present' do
          let(:attributes) do
            {
              service_metadata: nil,
              fixture: nil,
              asset_precompile: true
            }
          end

          it 'returns nil' do
            expect(load_service_metadata.to_h).to be(nil)
          end
        end

        context 'when asset pipeline is not present' do
          let(:attributes) do
            {
              service_metadata: nil,
              fixture: nil,
              asset_precompile: nil
            }
          end

          it 'returns the service metadata' do
            expect {
              load_service_metadata.to_h
            }.to raise_error(LoadServiceMetadata::ServiceMetadataNotFoundError)
          end
        end
      end
    end

    context 'when metadata is invalid' do
      let(:attributes) do
        {
          service_metadata: %({ "service_name": "Luke" }),
          fixture: nil,
          asset_precompile: nil
        }
      end

      it 'raises JSON schema validation error' do
        expect {
          load_service_metadata.to_h
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
