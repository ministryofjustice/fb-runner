class ServiceMetadataNotFoundError < StandardError
end

fixture =  MetadataPresenter::Engine.root.join('fixtures', 'version.json')

if File.exist?(fixture)
  Rails.configuration.service_metadata = JSON.parse(File.read(fixture))

  Rails.configuration.service = MetadataPresenter::Service.new(
    Rails.configuration.service_metadata
  )
else
  raise ServiceMetadataNotFoundError.new('No service metadata found')
end
