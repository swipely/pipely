require 'digest/md5'

module Pipely
  module Deploy

    #
    # Manage syncing of local files to a particular S3 path
    #
    class S3Uploader

      attr_reader :bucket_name
      attr_reader :s3_path

      def initialize(s3_bucket, s3_path)
        @s3_bucket = s3_bucket
        @bucket_name = s3_bucket.name
        @s3_path = s3_path
      end

      def s3_file_path(file)
        filename = File.basename(file)
        File.join(@s3_path, filename)
      end

      def s3_urls(files)
        files.map do |file|
          File.join("s3://", @s3_bucket.name, s3_file_path(file) )
        end
      end

      def upload(files)
        files.each do |file|
          upload_file(file)
        end
      end

      #
      # Upload file to S3 unless ETAGs already match.
      #
      def upload_file(file)
        target_path = s3_file_path(file)
        s3_object = @s3_bucket.objects[target_path]

        content = File.read(file)
        digest = Digest::MD5.hexdigest(content)

        if s3_object.exists? && (digest == s3_object.etag.gsub('"', ''))
          puts "skipping #{file} to #{target_path} (ETAG matches)"
        else
          puts "uploading #{file} to #{target_path}"
          s3_object.write(content)
        end
      end

    end

  end
end
