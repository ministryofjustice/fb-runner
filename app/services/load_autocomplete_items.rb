class LoadAutocompleteItems
  def initialize(autocomplete_items:, fixture:)
    @autocomplete_items = autocomplete_items
    @fixture = MetadataPresenter::Engine.root.join('fixtures', "#{fixture}.json")
  end

  def to_h
    if metadata_to_load && valid_metadata?
      metadata_to_load
    end
  end

  def metadata_to_load
    @metadata_to_load ||= begin
      if @autocomplete_items.blank? && File.exist?(@fixture)
        Rails.logger.debug("Loading fixture #{@fixture}")
        return JSON.parse(File.read(@fixture))
      end

      return JSON.parse(@autocomplete_items) if @autocomplete_items.present?
    end
  end

  def valid_metadata?
    return if metadata_to_load.blank?

    metadata_to_load.each do |_, items|
      MetadataPresenter::ValidateSchema.validate(items, 'definition.select')
    end
  end
end
