Rails.application.reloader.to_prepare do
  Rails.configuration.service_metadata = LoadServiceMetadata.new(
    service_metadata: ENV['SERVICE_METADATA'],
    fixture: ENV['SERVICE_FIXTURE'],
    asset_precompile: ENV['ASSET_PRECOMPILE']
  ).to_h

  Rails.configuration.service = MetadataPresenter::Service.new(
    Rails.configuration.service_metadata
  )
end
