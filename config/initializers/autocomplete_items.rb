Rails.application.reloader.to_prepare do
  Rails.configuration.autocomplete_items = LoadAutocompleteItems.new(
    service_id: ENV['SERVICE_ID'],
    autocomplete_items: ENV['AUTOCOMPLETE_ITEMS'],
    fixture: ENV['AUTOCOMPLETE_FIXTURE']
  ).to_h
end
