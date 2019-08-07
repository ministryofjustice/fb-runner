require 'json'
require 'tempfile'

class Page
  attr_reader :path, :config, :service

  def initialize(path:, config:, service:)
    @path = path
    @config = config
    @service = service
  end

  def id
    hash['page']['_id']
  end

  def start?
    hash["page"]["_type"] == "page.start"
  end

  def render
    file = Tempfile.new
    template = File.open(Rails.root.join('config', 'render.js.erb'), 'r').read
    erb = ERB.new(template)
    output = erb.result(binding)
    file.write(output)
    file.close

    Rails.logger.debug(pp @hash)

    `node #{file.path}`
  end

  def url
    hash["page"]["url"]
  end

  def steps
    hash["page"]["steps"]
  end

  def parent_page
    service.pages.find do |page|
      (page.steps || []).include?(self.id)
    end
  end

  private

  def hash
    return @hash if @hash

    @hash ||= ActiveSupport::HashWithIndifferentAccess.new({ 'page' => JSON.parse(File.read(path)) })

    @hash['page'].merge!('actions': {
      "$source": "@ministryofjustice/fb-components-core",
      "_id": "actions",
      "_type": "actions",
      "primary": {
        "_id": "actions.primary",
        "_type": "button",
        "html": "Start",
        "classes": "govuk-button--start",
        "$component": true,
        "$control": true,
        "$definition": true,
        "disabled": false,
        "show": true
      }
    })

    Massagers::Pages::Body.new(hash: @hash).call
    Massagers::Components::Date.new(hash: @hash).call

    @hash.merge!({ '_csrf': config[:csrf] })

    @hash
  end
end
