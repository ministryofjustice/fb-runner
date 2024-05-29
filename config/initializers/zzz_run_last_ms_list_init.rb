Rails.application.reloader.to_prepare do
  if ENV['MS_SITE_ID'] == 'test'
    puts('Initialising ms list')
    adapter = Platform::MicrosoftGraphAdapter.new
    adapter.service = Rails.configuration.service
    puts adapter.post_list_columns
  else
    puts('Skipping ms list init')
  end
end