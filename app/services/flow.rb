class Flow
  attr_reader :service, :page

  def initialize(service:, page:)
    @service = service
    @page = page
  end

  def previous_page
    return nil if page.start?

    candidate = service.start_page
    counter = 0

    loop do
      flow = Flow.new(service: service, page: candidate)

      if flow.next_page == page
        break
      else
        candidate = flow.next_page
      end

      counter = counter + 1

      if counter == 1000
        raise StandardError.new('out of flow page detected')
      end
    end

    return candidate
  end

  def next_page
    return @next_page if @next_page
    return if page.nil?

    steps = page.steps || page.parent_page.steps

    next_step_id = if steps.index(page.id)
      next_step_index = steps.index(page.id) + 1
      steps[next_step_index]
    else
      steps[0]
    end

    @next_page ||= service.find_page_by_id(next_step_id)
  end
end
