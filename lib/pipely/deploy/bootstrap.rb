require 'set'
require 'pipely/bundler'
require 'pipely/deploy/bootstrap_context'

module Pipely
  module Deploy

    # Helps bootstrap a pipeline
    class Bootstrap

      attr_reader :bucket_name
      attr_reader :s3_gems_path
      attr_reader :project_spec
      attr_reader :gem_files

      def initialize(s3_bucket, s3_gems_path)
        @s3_bucket = s3_bucket
        @bucket_name = s3_bucket.name
        @s3_gems_path = s3_gems_path
        @always_upload = Set.new
      end

      # Builds the project's gem from gemspec, uploads the gem to s3, and
      # uploads all the gem dependences to S3
      def build_and_upload_gems

        @gem_files = gems_from_bundler.each do |name, file_path|
          # Always upload the always upload, otherise
          # only upload gem if it doesnt exist

          if @always_upload.include?(name) || !s3_gem_exists?( file_path )
            upload_gem(file_path)
          end
        end

        gem_spec = Dir.glob("*.gemspec").first
        if gem_spec
          # Build pipeline gem
          @project_spec = Gem::Specification::load(gem_spec)
          @gem_files.merge!(Pipely::Bundler.build_gem(Dir.pwd))
          upload_gem(@gem_files[@project_spec.name])
        end
      end

      def context
        BootstrapContext.new(
          @gem_files.map{ |name, file|
            File.join("s3://", @s3_bucket.name, gem_s3_path(file) )
          } )
      end

      def gem_s3_path(gem_file)
        filename = File.basename(gem_file)
        File.join(@s3_gems_path, filename)
      end

      def s3_gem_exists?( gem_file )
        @s3_bucket.objects[gem_s3_path(gem_file)].exists?
      end

      def upload_gem( gem_file )
        puts "uploading #{gem_file} to #{gem_s3_path(gem_file)}"
        @s3_bucket.objects[gem_s3_path(gem_file)].write(File.open(gem_file))
      end

      def gems_from_bundler
        gem_files = Pipely::Bundler.packaged_gems

        Pipely::Bundler.build_gems_from_source.each do |name,path|
          @always_upload << name
          gem_files[name] = path
        end

        gem_files
      end
    end
  end
end
