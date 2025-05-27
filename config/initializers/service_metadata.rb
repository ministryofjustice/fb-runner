require 'ostruct'

Rails.application.reloader.to_prepare do
  begin
    Rails.configuration.service_metadata = LoadServiceMetadata.new(
      service_id: ENV['SERVICE_ID'],
      service_metadata: ENV['SERVICE_METADATA'],
      fixture: ENV['SERVICE_FIXTURE'],
      asset_precompile: ENV['ASSET_PRECOMPILE']
    ).to_h

    Rails.configuration.service = MetadataPresenter::Service.new(
      Rails.configuration.service_metadata
    )
  rescue LoadServiceMetadata::ServiceMetadataNotFoundError,
         JSON::Schema::ValidationError => e
    Sentry.capture_exception(e)
    Rails.logger.fatal(e.message)
    fail
  end
end
