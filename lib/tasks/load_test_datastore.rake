namespace :load_test do
  desc "
  Load test the datastore
  Usage
  rake load_test:engage[service_slug]
  "
  task :engage, [:slug] => :environment do |_t, args|
    slug = args[:slug]

    Fb::Jwt::Auth.configure do |config|
      config.issuer = slug
      config.namespace = "formbuilder-services-test-dev"
      config.encoded_private_key = ENV['ENCODED_PRIVATE_KEY']
    end

    subject = SecureRandom.uuid
    token = Fb::Jwt::Auth::ServiceAccessToken.new(
      subject: subject
    ).generate

    system("'#{Rails.root.join('bin', 'load_test_datastore')}' '#{token}' '#{ENV['DATASTORE_URL']}' '#{subject}' '#{slug}'")
  end
end
