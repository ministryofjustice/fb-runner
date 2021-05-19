class MissingFilestoreUrlError < StandardError
end

class FileUploader
  include ActiveModel::Model
  attr_accessor :session, :page_answers, :component

  def upload
    if ENV['FILESTORE_URL'].blank?
      raise MissingFilestoreUrlError if Rails.env.production?

      OfflineUploadAdapter.new.call
    else
      user_filestore_payload = Platform::UserFilestorePayload.new(
        session,
        file_details: file_details
      ).call
      Platform::UserFilestoreAdapter.new(
        session,
        payload: user_filestore_payload
      ).call
    end
  end

  private

  def file_details
    @page_answers.send(component.id)
  end
end
