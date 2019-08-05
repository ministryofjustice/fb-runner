class Flow
  attr_reader :service, :page

  def initialize(service:, page:)
    @service = service
    @page = page
  end

  def next_page
    step = page.steps[0]
    service.find_page_by_id(step)
  end
end
