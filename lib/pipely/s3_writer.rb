require 'aws-sdk'

module Pipely

  # Writes content from a String to an S3 path
  #
  class S3Writer

    def initialize(s3_path)
      uri = URI.parse(s3_path)
      @host, @path = uri.host, uri.path.gsub(/^\//,'')
    end

    def write(content)
      s3_bucket = Aws::S3::Bucket.new(@host)
      s3_object = s3_bucket.object(@path)
      s3_object.put(body: content, acl: 'public')
      s3_object.public_url
    end
  end
end
