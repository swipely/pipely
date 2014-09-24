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
        gem_spec = Dir.glob("*.gemspec").first
        if gem_spec
          # project gem spec
          @project_spec = Gem::Specification::load(gem_spec)
        else
          raise "Failed to find pipeline's gemspec"
        end

        @gem_files = gems_from_bundler(@project_spec.name)
        upload_gems(@gem_files, @always_upload)

        # Project gem should be at the bottom of the dep list
        @gem_files.merge!(
          Pipely::Bundler.build_gem(@project_spec.name, Dir.pwd))
        upload_gem(@gem_files[@project_spec.name])

        @gem_files
      end

      def context(s3_steps_path)
        BootstrapContext.new.tap do |context|
          context.gem_files = @gem_files.map do |name, file|
            File.join("s3://", @s3_bucket.name, gem_s3_path(file) )
          end
          context.s3_steps_path = s3_steps_path
        end
      end

      def gem_s3_path(gem_file)
        filename = File.basename(gem_file)
        File.join(@s3_gems_path, filename)
      end

      def s3_gem_exists?( gem_file )
        @s3_bucket.objects[gem_s3_path(gem_file)].exists?
      end

      def upload_gems(gem_files, always_upload)
        gem_files.each do |name, file_path|

          # Always upload the always upload, otherise
          # only upload gem if it doesnt exist
          if always_upload.include?(name) || !s3_gem_exists?( file_path )
            upload_gem(file_path)
          end
        end
      end

      def upload_gem( gem_file )
        puts "uploading #{gem_file} to #{gem_s3_path(gem_file)}"
        @s3_bucket.objects[gem_s3_path(gem_file)].write(File.open(gem_file))
      end

      def gems_from_bundler(*gems_to_exclude)
        # Always exclude bundler
        gems_to_exclude << 'bundler'

        gem_files = Pipely::Bundler.packaged_gems do |specs|
          specs.reject { |s| gems_to_exclude.include?(s.name) }
        end

        Pipely::Bundler.build_gems_from_source do |sources|
          sources.reject { |s| gems_to_exclude.include?(s.name) }
        end.each do |name,path|
          # XXX: using an instance var to track if the gem should be
          #      uploaded is clumsy
          @always_upload << name
          gem_files[name] = path
        end

        gem_files
      end
    end
  end
end
