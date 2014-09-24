module Pipely

  #
  # Provides access to Bundler's list of gems
  #
  module Bundler
    extend self

    SOURCE_TYPES = %w[Bundler::Source::Git Bundler::Source::Path]

    class GemBuildError < RuntimeError ; end

    def gem_names(groups=[:default])
      ::Bundler.definition.specs_for(groups).map(&:name)
    end

    def locked_sources(groups=[:default])
      names_of_gems = gem_names(groups)
      locked_sources =
        ::Bundler.definition.instance_variable_get(:@locked_sources)

      locked_sources.select do |source|
        # Only include gems for the correct bundler group
        names_of_gems.include?(source.name) &&

        # Only build for git and path sources
        SOURCE_TYPES.include?(source.class.name)
      end
    end

    def packaged_gems(groups=[:default], &blk)
      gem_files = {}
      specs = ::Bundler.definition.specs_for(groups)

      # Do not package source gems
      source_gem_names = locked_sources(groups).map(&:name)
      specs = specs.to_a.reject { |s| source_gem_names.include?(s.name) }

      # allow custom filtering of gems
      specs = yield(specs, groups) if blk

      specs.each do |spec|
        gem_files.merge!(package_gem(spec))
      end

      gem_files
    end

    def package_gem(spec)
      gem_file = spec.cache_file

      # Reuse the downloaded gem
      if File.exists? gem_file
        {spec.name => gem_file}

      # Some gems do not exist in the cache, e.g. json. Looks like
      # the gems are shipped with the ruby dist, so they will built
      # into gems
      else
        build_gem(spec.name, spec.gem_dir)
      end
    end

    def build_gems_from_source(groups=[:default], &blk)
      gem_files = {}
      sources = locked_sources(groups)
      sources = yield(sources) if blk
      sources.each do |source|
        gem_files.merge!( build_gem(source.name, source.path) )
      end
      gem_files
    end

    def build_gem(spec_name, source_path)
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
