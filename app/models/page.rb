require 'json'

class Page
  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def start?
    hash["_type"] == "page.start"
  end

  private

  def hash
    @hash ||= JSON.parse(File.read(path))
  end
end
