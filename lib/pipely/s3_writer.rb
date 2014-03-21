require 'fog/storage'

module Pipely

  # Writes content from a String to an S3 path
  #
  class S3Writer

    def initialize(s3_path)
      uri = URI.parse(s3_path)
      @host, @path = uri.host, uri.path.gsub(/^\//,'')
    end

    def directory
      directory = storage.directories.detect{ |d| d.key == @host }

      directory or raise("Couldn't find S3 bucket '#{@host}'")
    end

    def write(content)
      remote_file = directory.files.create({
        :key => @path,
        :body => content,
        :public => true,
      })

      remote_file.public_url
    end

    private

      def storage
        Fog::Storage.new({ provider: 'AWS' })
      rescue ArgumentError
        $stderr.puts "#{self.class.name}: Falling back to IAM profile"
        Fog::Storage.new({ provider: 'AWS', use_iam_profile: true })
      end

  end

end
