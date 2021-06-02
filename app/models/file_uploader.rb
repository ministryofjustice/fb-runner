class MissingFilestoreUrlError < StandardError
end

class FileUploader
  include ActiveModel::Model
  attr_accessor :session, :page_answers, :component

  def upload
    UploadedFile.new(file: adapter.call, component: component)
  end

  def adapter
    if ENV['USER_FILESTORE_URL'].blank?
      raise MissingFilestoreUrlError if Rails.env.production?

      OfflineUploadAdapter.new
    else
      user_filestore_payload = Platform::UserFilestorePayload.new(
        session,
        file_details: file_details,
        allowed_file_types: component.validation['accept']
      ).call

      Platform::UserFilestoreAdapter.new(
        session,
        payload: user_filestore_payload
      )
    end
  end

  private

  def file_details
    @page_answers.send(component.id)
  end
end
