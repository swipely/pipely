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
      storage = Fog::Storage.new({ provider: 'AWS' })
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

  end

end
