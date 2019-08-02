require 'json'
require 'tempfile'

class Page
  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def start?
    hash["_type"] == "page.start"
  end

  def render
    file = Tempfile.new
    template = File.open(Rails.root.join('config', 'render.js.erb'), 'r').read
    erb = ERB.new(template)
    output = erb.result(binding)
    file.write(output)
    file.close

    Rails.logger.info(file.path)

    `node #{file.path}`
  end

  private

  def hash
    @hash ||= JSON.parse(File.read(path))

    @hash.merge!('buttonContinue' => {
                   "_id": "actions",
                   "_type": "actions",
                   "primary": {
                     "_id": "actions.primary",
                     "_type": "button",
                     "html": "[% button.{page@actionType}.{page@_type} || button.{page@actionType} || button.continue %]",
                     "classes": "[% button.{page@actionType}.{page@_type}.classes || button.{page@actionType}.classes %]"
                     }
                 })

    # awful
    # use specifications/definition/page/definition.page.schema.json
    # to determine when to use markdown
    if @hash['body']
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      @hash['body'] = markdown.render(@hash['body'])
    end

    @hash
  end
end
