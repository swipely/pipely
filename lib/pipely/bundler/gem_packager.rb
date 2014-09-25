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

      def package(spec)
        gem_file = spec.cache_file

        # Reuse the downloaded gem
        if File.exists? gem_file
          {spec.name => gem_file}

        # Some gems do not exist in the cache, e.g. json. Looks like
        # the gems are shipped with the ruby dist, so they will built
        # into gems
        else
          build_from_source(spec.name, spec.gem_dir)
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
        end

        {gem_spec.name => File.join(source_path,gem_file)}
      end
    end
  end
end
