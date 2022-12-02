RSpec.describe AwsS3Client do
  subject(:aws_s3_client) do
    described_class.new
  end

  describe '#get_object' do
    let(:bucket) { 'some-bucket' }
    let(:object_key) { 'some-object-key' }
    let(:response) { double(body: double(read: 'data')) }

    let(:s3_object_stub) do
      s3 = Aws::S3::Client.new(stub_responses: true)
      s3.stub_responses(:get_object, { body: 'Hello!' })
      s3
    end

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('BUCKET_NAME').and_return(bucket)
      allow_any_instance_of(AwsS3Client).to receive(:s3).and_return(s3_object_stub)
    end

    it 'should get an object from s3' do
      expect(s3_object_stub).to receive(:get_object).with(
        bucket: bucket,
        key: object_key
      ).and_return(response)

      aws_s3_client.get_object(object_key)
    end

    it 'should read a response body' do
      expect(aws_s3_client.get_object(object_key)).to eq('Hello!')
    end
  end
end
