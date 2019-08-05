class Service
  attr_accessor :path, :config

  def initialize(path:, config:)
    @path = path
    @config = config
  end

  def pages
    @pages ||= Dir.glob("#{path}/metadata/page/*.json").map do |page_path|
      Page.new(path: page_path, config: config)
    end
  end

  def start_page
    pages.find { |p| p.start? }
  end

  def find_page_for_url(url)
    pages.find { |page| page.url == url }
  end

  def find_page_by_id(id)
    pages.find { |page| page.id == id }
  end
end
