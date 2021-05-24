class UploadedFile
  include ActiveModel::Model
  attr_accessor :file, :component

  def ==(other)
    file == other.file && component == other.component
  end

  def error_name
    file.error_name if file.respond_to? :error_name
  end
end
