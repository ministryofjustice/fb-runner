class UserDatastoreAdapter
  class DatastoreTimeoutError < StandardError; end
  TIMEOUT = 15

  attr_reader :session, :root_url, :service_slug

  def initialize(session, root_url: ENV['DATASTORE_URL'], service_slug: ENV['SERVICE_SLUG'])
    @session = session
    @root_url = root_url
    @service_slug = service_slug
  end

  def save(params)
    existing_answers = load_data
    all_answers = existing_answers.merge(params)

    body = {
      payload: data_encryption.encrypt(all_answers.to_json)
    }

    request(:post, JSON.generate(body))
  end

  def load_data
    response = JSON.parse(request(:get, {}).body)['payload'] || {}

    JSON.parse(data_encryption.decrypt(response)) || {}
  end

  private

  def data_encryption
    # TODO: change to session token?
    @data_encryption = DataEncryption.new(key: subject)
  end

  def url
    "/service/#{service_slug}/user/#{subject}"
  end

  def subject
    session[:session_id]
  end

  def headers
    {
      'x-access-token-v2' => ServiceAccessToken.new(subject: subject).generate,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Runner'
    }
  end

  def connection
    @connection ||= Faraday.new(
      root_url, request: { open_timeout: TIMEOUT, timeout: TIMEOUT }
    )
  end

  def request(verb, body)
    connection.send(verb, url, body, headers)
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => exception
    raise DatastoreTimeoutError.new(exception.message)
  end
end
