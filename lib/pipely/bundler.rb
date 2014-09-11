module Pipely

  #
  # Provides access to Bundler's list of gems
  #
  module Bundler
    extend self

    SOURCE_TYPES = %w[Bundler::Source::Git Bundler::Source::Path]

    def gem_names(groups=[:default])
      ::Bundler.definition.specs_for(groups).map(&:name)
    end

    def packaged_gems(groups=[:default])
      gem_files = {}
      ::Bundler.definition.specs_for(groups).each do |spec|
        gem_file = spec.cache_file

        # XXX: Some gems do not exist in the cache, e.g. json. Looks the
        #      gem is already packaged with the ruby dist
        if File.exists? gem_file
            gem_files[spec.name] = gem_file
        end
      end

      gem_files
    end

    def build_gems_from_source(groups=[:default])

      gem_files = {}
      names_of_gems = gem_names(groups)
      locked_sources =
        ::Bundler.definition.instance_variable_get(:@locked_sources)

      locked_sources.select! do |source|
        # Only include gems for the correct bundler group
        names_of_gems.include?(source.name) &&

        # Only build for git and path sources
        SOURCE_TYPES.include?(source.class.name)
      end

      locked_sources.each do |source|
        gem_files.merge build_gem(source.path)
      end

      gem_files
    end

    def build_gem(source_path)
      present_dir = Dir.pwd
      gem_spec_path = Dir.glob(File.join(source_path, "*.gemspec")).first
      if gem_spec_path

        # Build the gemspec
        gem_spec = Gem::Specification::load(gem_spec_path)

        # build the gem
        Dir.chdir( source_path )
        source_gem_file =
          `gem build #{gem_spec_path}`.scan(
            /File:(.+.gem)$/).flatten.first.strip
        Dir.chdir( present_dir )

        {gem_spec.name => File.join(source_path,source_gem_file)}
      else
        {}
      end
    end
  end
end
