require 'fileutils'
require 'rubygems/remote_fetcher'

module Pipely
  module Bundler

    #
    # Builds cache files for git- or path-sourced gems.
    #
    class GemPackager

      # Alert upon gem-building failures
      class GemBuildError < RuntimeError ; end

      # Alert upon gem-fetching failures
      class GemFetchError < RuntimeError ; end

      def initialize(vendor_dir)
        @vendor_dir = vendor_dir
        unless Dir.exists? @vendor_dir
          FileUtils.mkdir_p(@vendor_dir)
        end
      end

      def package(spec)
        if vendored_gem = vendor_local_gem(spec)
          vendored_gem

        # Finally, some gems do not exist in the cache or as source.  For
        # instance, json is shipped with the ruby dist. Try to fetch directly
        # from rubygems.
        else
          gem_file_name = "#{spec.name}-#{spec.version}.gem"
          { spec.name => download_from_rubygems(gem_file_name)}
        end
      end

      def vendor_local_gem(spec)
        gem_file = spec.cache_file
        vendored_gem = File.join( @vendor_dir, File.basename(gem_file) )

        if File.exists?(vendored_gem)
          { spec.name => vendored_gem }

        # Gem exists in the local ruby gems cache
        elsif File.exists? gem_file

          # Copy to vendor dir
          FileUtils.cp(gem_file, vendored_gem)

          { spec.name => vendored_gem }

        # If source exists, build a gem from it
        elsif File.directory?(spec.gem_dir)
          build_from_source(spec.name, spec.gem_dir)
        else
          nil
        end
      end

      def build_from_source(spec_name, source_path)
        gem_spec_path = "#{spec_name}.gemspec"

        # Build the gemspec
        gem_spec = Gem::Specification::load(
          File.join(source_path,gem_spec_path))

        gem_file = build_gem(spec_name, source_path)

        # Move to vendor dir
        FileUtils.mv(
          File.join(source_path,gem_file),
          File.join(@vendor_dir,gem_file))

        { gem_spec.name => File.join(@vendor_dir, gem_file) }
      end

      def build_gem(spec_name, source_path)
        gem_spec_path = "#{spec_name}.gemspec"

        Dir.chdir(source_path) do
          result = `gem build #{gem_spec_path} 2>&1`

          if result =~ /ERROR/i
            raise GemBuildError.new(
              "Failed to build #{gem_spec_path} \n" << result)
          else
            result.scan(
                /File:(.+.gem)$/).flatten.first.strip
          end
        end
      end

      def download_from_rubygems(gem_file_name)
        vendored_gem = File.join( @vendor_dir, gem_file_name )

        # XXX: add link on wiki details what is going on here
        puts "Fetching gem #{gem_file_name} directly from rubygems, most " +
             "likely this gem was packaged along with your ruby " +
             "distrubtion, for more details see LINK"

        ruby_gem_url = "https://rubygems.org/downloads/#{gem_file_name}"

        fetcher = Gem::RemoteFetcher.new
        gem_data = fetcher.fetch_path(ruby_gem_url)
        IO.binwrite(vendored_gem, gem_data)

        vendored_gem
      end
    end
  end
end
