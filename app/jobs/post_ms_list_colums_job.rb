class PostMSListColumnsJob < ApplicationJob
  def perform(service)
    adapter = Platform::MicrosoftGraphAdapter.new
    adapter.service = service

    adapter.post_list_columns
  end
end
