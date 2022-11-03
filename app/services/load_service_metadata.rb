require 'fileutils'

class LoadServiceMetadata
  class ServiceMetadataNotFoundError < StandardError
  end

  include MetadataFiles

  def initialize(service_id:, service_metadata:, fixture:, asset_precompile:)
    @service_id = service_id
    @service_metadata = service_metadata
    @fixture = MetadataPresenter::Engine.root.join('fixtures', "#{fixture}.json")
    @asset_precompile = asset_precompile
  end

  METADATA_FILE = 'metadata.json'.freeze

  def to_h
    metadata = metadata_to_load
    return metadata if metadata.present? && valid_metadata?(metadata)

    raise ServiceMetadataNotFoundError, error_message if @asset_precompile.blank?
  end

  def metadata_to_load
    return download_metadata(object_key) if @service_id.present?

    if @service_metadata.blank? && File.exist?(@fixture)
      puts("Loading fixture #{@fixture}")
      return JSON.parse(File.read(@fixture))
    end

    if @service_metadata.present?
      Rails.logger.info('Loading service metadata from environment')
      JSON.parse(@service_metadata)
    end
  end

  def object_key
    "#{@service_id}_#{METADATA_FILE}"
  end

  def valid_metadata?(metadata)
    MetadataPresenter::ValidateSchema.validate(metadata, 'service.base')
    Array(metadata['pages']).each do |page|
      MetadataPresenter::ValidateSchema.validate(page, page['_type'])
    end
  end

  def error_message
    <<~HEREDOC
      No service metadata found.

      if you want to run in development you can pass a fixture
      from the metadata presenter gem instead:

      ENV['SERVICE_FIXTURE']='version' rails s

      If you want to pass the actual metadata you can do via:

      ENV['SERVICE_METADATA']='{ ... json ... }' rails s

      Values of each env var:
      ENV['SERVICE_METADATA'] = '#{ENV['SERVICE_METADATA']}'
      ENV['SERVICE_FIXTURE'] = '#{ENV['SERVICE_FIXTURE']}'
    HEREDOC
  end
end
