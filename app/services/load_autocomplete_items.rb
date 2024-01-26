require 'fileutils'

class LoadAutocompleteItems
  include MetadataFiles

  def initialize(service_id:, autocomplete_items:, fixture:)
    @service_id = service_id
    @autocomplete_items = autocomplete_items
    @fixture = MetadataPresenter::Engine.root.join('fixtures', "#{fixture}.json")
  end

  AUTOCOMPLETE_FILE = 'autocomplete_items.json'.freeze

  def to_h
    metadata = metadata_to_load
    metadata if metadata.present? && valid_metadata?(metadata)
  end

  def metadata_to_load
    return download_metadata(object_key) if @service_id.present?

    if @autocomplete_items.blank? && File.exist?(@fixture)
      Rails.logger.debug("Loading fixture #{@fixture}")
      return JSON.parse(File.read(@fixture))
    end

    if @autocomplete_items.present?
      Rails.logger.info('Loading autocomplete items from environment')
      JSON.parse(@autocomplete_items)
    end
  end

  def object_key
    "#{@service_id}_#{AUTOCOMPLETE_FILE}"
  end

  def valid_metadata?(metadata)
    return if metadata.blank?

    metadata.each_value do |items|
      MetadataPresenter::ValidateSchema.validate(items, 'definition.select')
    end
  end
end
