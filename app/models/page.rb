require 'json'
require 'tempfile'

class Page
  attr_reader :path, :config, :service

  def initialize(path:, config:, service:)
    @path = path
    @config = config
    @service = service
  end

  def http_method
    config[:http_method]
  end

  def id
    in_hash['page']['_id']
  end

  def type
    in_hash['page']['_type']
  end

  def start?
    in_hash["page"]["_type"] == "page.start"
  end

  def valid?
    components.all? { |c| c.valid? }
  end

  def form_fields
    (in_hash.try(:[], :page).try(:[], :components) || []).map{|c| c[:name]}
  end

  def render
    file = Tempfile.new
    template = File.open(Rails.root.join('config', 'render.js.erb'), 'r').read
    erb = ERB.new(template)
    output = erb.result(binding)
    file.write(output)
    file.close

    Rails.logger.debug(pp @out_hash)

    `node #{file.path}`
  end

  def components
    @components ||= (in_hash["page"].try(:[], "components") || []).map do |c|
      Component.new_from_hash(c, config: config)
    end
  end

  def url
    in_hash["page"]["url"]
  end

  def steps
    in_hash["page"]["steps"]
  end

  def parent_page
    service.pages.find do |page|
      (page.steps || []).include?(self.id)
    end
  end

  def update_userdata(params)
    permitted_data = params.permit(form_fields)

    @in_hash = nil

    service.data.merge(permitted_data)
  end

  private

  def base_template
    Rails.root.join(Dir.glob("node_modules/@ministryofjustice/fb-components-core/specifications/page/*/template/nunjucks/#{type}.njk.html")[0])
  end

  def in_hash
    return @in_hash if @in_hash

    @in_hash = ActiveSupport::HashWithIndifferentAccess.new({ 'page' => JSON.parse(File.read(path)) })

    Massagers::Data::Inject.new(hash: @in_hash, data: service.data).call

    @in_hash
  end

  def out_hash
    return @out_hash if @out_hash

    @out_hash = { 'page' => {
                    'components' => []
                   }
                }

    @out_hash['page'].merge!('actions': {
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

    Massagers::Pages::Header.new(in_hash: in_hash, out_hash: @out_hash).call
    Massagers::Pages::Previous.new(in_hash: in_hash, out_hash: @out_hash, page: self, service: service).call
    Massagers::Pages::Body.new(in_hash: in_hash, out_hash: @out_hash).call
    Massagers::Pages::Headings.new(in_hash: in_hash, out_hash: @out_hash).call

    components.each do |c|
      @out_hash['page']['components'] << c.to_hash
    end

    Massagers::Service.new(in_hash: in_hash, out_hash: @out_hash).call

    @out_hash.merge!({ '_csrf': config[:csrf] })
    @out_hash.merge!({ 'govuk_frontend_version': '3.3.0' })

    @out_hash
  end
end
