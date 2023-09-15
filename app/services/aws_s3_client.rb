require 'aws-sdk-s3'

class AwsS3Client
  REGION = 'eu-west-2'.freeze

  def get_object(object_key)
    response = s3.get_object(bucket: ENV['BUCKET_NAME'], key: object_key)
    response.body.read
  end

  private

  def s3
    @s3 ||= Aws::S3::Client.new(region: REGION)
  end
end
