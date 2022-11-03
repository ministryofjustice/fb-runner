module MetadataFiles
  SERVICE_METADATA_DIRECTORY = Rails.root.join('tmp', 'service_metadata').freeze

  def download_metadata(key)
    FileUtils.mkdir_p(SERVICE_METADATA_DIRECTORY) unless File.exist?(SERVICE_METADATA_DIRECTORY)

    Rails.logger.info("Downloading #{key} from S3")
    metadata = s3_client.get_object(key)
    File.write(File.join(SERVICE_METADATA_DIRECTORY, key), metadata)
    JSON.parse(metadata)
  rescue Aws::S3::Errors::ServiceError => e
    Sentry.capture_exception(e)
    nil
  end

  def s3_client
    @s3_client ||= AwsS3Client.new
  end
end
