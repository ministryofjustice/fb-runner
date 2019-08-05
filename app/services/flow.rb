class Flow
  attr_reader :service, :page

  def initialize(service:, page:)
    @service = service
    @page = page
  end

  def next_page
    steps = page.steps || page.parent_page.steps

    next_step_id = if steps.index(page.id)
      next_step_index = steps.index(page.id) + 1
      steps[next_step_index]
    else
      steps[0]
    end

    service.find_page_by_id(next_step_id)
  end
end
