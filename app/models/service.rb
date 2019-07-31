class Service
  attr_accessor :path

  def initialize(path:)
    @path = path
  end

  def pages
    Dir.glob("#{path}/metadata/page/*.json").map do |page_path|
      Page.new(path: page_path)
    end
  end

  def start_page
    pages.find { |p| p.start? }
  end
end
