Capybara.add_selector(:data_content_id) do
  xpath { |name| XPath.css("[data-fb-content-id='#{name}']") }
end

module DataContentId
  def data_content_id(method_name, content_id)
    element(method_name, :data_content_id, content_id)
  end
end
