RSpec.describe LoadServiceMetadata do
  subject(:load_service_metadata) { described_class.new(attributes) }

  describe '#to_h' do
    let(:service_id) { nil }
    let(:service_metadata) { nil }
    let(:fixture) { nil }
    let(:asset_precompile) { nil }
    let(:attributes) do
      {
        service_id: service_id,
        service_metadata: service_metadata,
        fixture: fixture,
        asset_precompile: asset_precompile
      }
    end

    context 'when there is no service id present' do
      context 'when service metadata is present' do
        let(:service_metadata) do
          File.read(
            MetadataPresenter::Engine.root.join('fixtures', 'service.json')
          )
        end

        it 'returns the service metadata' do
          expect(load_service_metadata.to_h).to eq(JSON.parse(service_metadata))
        end
      end

      context 'when service metadata is blank' do
        context 'when fixture is present' do
          let(:fixture) { 'version' }

          it 'returns the service metadata from fixture' do
            expect(load_service_metadata.to_h).to include(
              'service_name' => 'Version Fixture'
            )
          end
        end

        context 'when fixture is not present' do
          context 'when asset pipeline is present' do
            let(:asset_precompile) { true }

            it 'returns nil' do
              expect(load_service_metadata.to_h).to be(nil)
            end
          end

          context 'when asset pipeline is not present' do
            it 'returns the service metadata' do
              expect {
                load_service_metadata.to_h
              }.to raise_error(LoadServiceMetadata::ServiceMetadataNotFoundError)
            end
          end
        end
      end

      context 'when metadata is invalid' do
        let(:service_metadata) { %({ "service_name": "Luke" }) }

        it 'raises JSON schema validation error' do
          expect {
            load_service_metadata.to_h
          }.to raise_error(JSON::Schema::ValidationError)
        end
      end
    end

    context 'when there is a service id present' do
      let(:service_id) { SecureRandom.uuid }
      let(:file_body) do
        File.read(
          MetadataPresenter::Engine.root.join('fixtures', 'service.json')
        )
      end

      before do
        allow_any_instance_of(AwsS3Client).to receive(:get_object)
          .with(load_service_metadata.object_key)
          .and_return(file_body)
      end

      it 'should write the service metadata to file' do
        file_path = File.join(LoadServiceMetadata::SERVICE_METADATA_DIRECTORY, load_service_metadata.object_key)
        expect(File).to receive(:write).with(file_path, file_body)
        load_service_metadata.to_h
      end

      it 'should return the correct metadata' do
        expect(load_service_metadata.to_h).to eq(JSON.parse(file_body))
      end
    end
  end
end
