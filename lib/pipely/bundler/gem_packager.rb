require 'fileutils'
require 'excon'

module Pipely
  module Bundler

    #
    # Builds cache files for git- or path-sourced gems.
    #
    class GemPackager

      #
      # Alert upon gem-building failures
      #
      class GemBuildError < RuntimeError ; end
      class GemFetchError < RuntimeError ; end

      def initialize(dest)
        if Dir.exists? dest
          @dest = dest
        else
          raise "#{dest} does not exist"
        end
      end

      def package(spec)
        gem_file = spec.cache_file
        vendored_gem = File.join( @dest, File.basename(gem_file) )

        # Gem has already been vendored
        return { spec.name => vendored_gem } if File.exists?(vendored_gem)

        # Gem exists in the local ruby gems cache
        if File.exists? gem_file

          # Copy to vendor dir
          FileUtils.cp(gem_file, vendored_gem)

          { spec.name => vendored_gem }

        # If source exists, build a gem from it
        elsif File.directory?(spec.gem_dir)
          build_from_source(spec.name, spec.gem_dir)

        # Finally, some gems do not exist in the cache or as source.  For
        # instance, json is shipped with the ruby dist. Try to fetch directly
        # from rubygems.
        else
          gem_name = "#{spec.name}-#{spec.version}.gem"
          { spec.name => download_from_rubygems(gem_name)}
        end
      end

      def build_from_source(spec_name, source_path)
        gem_spec_path = "#{spec_name}.gemspec"

        # Build the gemspec
        gem_spec = Gem::Specification::load(
          File.join(source_path,gem_spec_path))

        gem_file = nil

        # build the gem
        Dir.chdir(source_path) do
          result = `gem build #{gem_spec_path} 2>&1`

          if result =~ /ERROR/i
            raise GemBuildError.new(
              "Failed to build #{gem_spec_path} \n" << result)
          else
            gem_file = result.scan(
                /File:(.+.gem)$/).flatten.first.strip
          end

          # Move to vendor dir
          FileUtils.mv(
            File.join(source_path,gem_file),
            File.join(@dest,gem_file))
        end

        { gem_spec.name => File.join(@dest, gem_file) }
      end

      def download_from_rubygems(gem_name)
        vendored_gem = File.join( @dest, gem_name )

        # XXX: add link on wiki details what is going on here
        puts "Fetching gem #{gem_name} directly from rubygems, most likely
              this gem was packaged along with your ruby distrubtion, see LINK
              for more details"

        ruby_gem_url = "https://rubygems.org/downloads/#{gem_name}"
        response = Excon.get( ruby_gem_url, {
          middlewares: Excon.defaults[:middlewares] +
                       [Excon::Middleware::RedirectFollower]
        })

        if response.status == 200
          File.open(vendored_gem, 'w') { |file| file.write( response.body ) }
          return vendored_gem
        else
          raise GemFetchError.new(
            "Failed to find #{gem_name} at rubygems, recieved
            #{response.status} with #{response.body}" )
        end
      end
    end
  end
end
