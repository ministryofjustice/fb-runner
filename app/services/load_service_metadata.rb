class LoadServiceMetadata
  class ServiceMetadataNotFoundError < StandardError
  end

  def initialize(service_metadata:, fixture:)
    @service_metadata = service_metadata
    @fixture = MetadataPresenter::Engine.root.join('fixtures', "#{fixture}.json")
  end

  def to_h
    if @service_metadata.blank?
      raise ServiceMetadataNotFoundError.new('No service metadata found') if Rails.env.production?

      if File.exist? @fixture
        puts("Loading fixture #{@fixture}")
        JSON.parse(File.read(@fixture))
      else
        raise ServiceMetadataNotFoundError.new(
          "No service metadata fixture found in #{fixture}"
        )
      end
    else
      JSON.parse(@service_metadata)
    end
  end
end

