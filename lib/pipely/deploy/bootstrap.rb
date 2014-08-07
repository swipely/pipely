require 'rubygems/package'

module Pipely
  module Deploy

    # Helps bootstrap a pipeline
    class Bootstrap

      attr_reader :bucket_name
      attr_reader :s3_gems_path
      attr_reader :project_spec

      def initialize(storage, bucket_name, s3_gems_path)
        @bucket_name = bucket_name
        @s3_gems_path = s3_gems_path

        unless @directory = storage.directories.get(@bucket_name)
          raise "Couldn't upload to S3 bucket #{@bucket_name}"
        end
      end

      # Builds the project's gem from gemspec, uploads the gem to s3, and
      # uploads all the gem dependences to S3
      def build_and_upload_gems

        # placeholder, name will be nil if a gemspec is not defined
        project_gem_name = nil

        gem_spec = Dir.glob("*.gemspec").first
        if gem_spec

          # Build pipeline gem
          @project_spec = Gem::Specification::load(gem_spec)
          project_gem_file = Gem::Package.build(@project_spec)
          project_gem_name = @project_spec.name
          upload_gem(project_gem_file)
        end

        @gem_files = upload_gems_from_bundler(project_gem_name)

        # project gem has to be loaded last
        @gem_files << project_gem_file if @project_spec
      end

      def install_gems_script
        script = ""

        @gem_files.each do |gem_file|
          filename = File.basename(gem_file)
          s3_path = File.join("s3://", @bucket_name, gem_s3_path(gem_file))
          script << %Q[
# #{filename}
hadoop fs -copyToLocal #{s3_path} /home/hadoop/#{filename}
gem install --local /home/hadoop/#{filename} --no-ri --no-rdoc
rbenv rehash"
          ]
        end

        script
      end

      private
      def gem_s3_path(gem_file)
        filename = File.basename(gem_file)
        File.join(@s3_gems_path, filename)
      end

      def s3_gem_exists?( gem_file )
        !@directory.files.get(gem_s3_path(gem_file)).nil?
      end

      def upload_gem( gem_file )
        puts "uploading #{gem_file} to #{gem_s3_path(gem_file)}"
        @directory.files.create(
          key: gem_s3_path(gem_file),
          body: File.open(gem_file) )
      end

      def upload_gems_from_bundler(project_gem_name)
        gem_files = []
        Bundler.definition.specs_for([:default]).each do |spec|
          # Exclude project from gem deps
          unless spec.name == project_gem_name
            gem_file = spec.cache_file

            # XXX: Some gems do not exist in the cache, e.g. json. Looks the
            #      gem is already packaged with the ruby dist
            if File.exists? gem_file
              gem_files << gem_file

              # only upload gem if it doesnt exist already
              unless s3_gem_exists?( gem_file )
                upload_gem(gem_file)
              end
            end
          end
        end

        gem_files
      end
    end
  end
end
