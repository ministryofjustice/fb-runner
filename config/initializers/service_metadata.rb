class ServiceMetadataNotFoundError < StandardError
end

if File.exist?(MetadataPresenter::Engine.root.join('spec', 'fixtures', 'version.json'))
  Rails.configuration.service_metadata = JSON.parse(
    File.read(MetadataPresenter::Engine.root.join('spec', 'fixtures', 'version.json'))
  )

  Rails.configuration.service = MetadataPresenter::Service.new(
    Rails.configuration.service_metadata
  )
else
  raise ServiceMetadataNotFoundError.new('No service metadata found')
end
