module Pipely
  module Bundler

    #
    # Builds the project's gem from gemspec and pulls in its dependencies via
    # the gem's bundle.
    #
    class ProjectGem

      attr_reader :project_spec

      def self.load
        if gem_spec = Dir.glob("*.gemspec").first
          # project gem spec
          new(Gem::Specification::load(gem_spec))
        else
          raise "Failed to find gemspec"
        end
      end

      def initialize(project_spec)
        @project_spec = project_spec
      end

      def gem_files
        # Project gem should be at the bottom of the dep list
        @gem_files ||= dependency_gem_files.merge(project_gem_file)
      end

      def dependency_gem_files(bundle=Pipely::Bundler::Bundle.build)
        # Always exclude bundler and the project gem
        gems_to_exclude = [ @project_spec.name, 'bundler' ]

        bundle.gem_files.reject { |name, path| gems_to_exclude.include?(name) }
      end

      def project_gem_file(gem_packager=Pipely::Bundler::GemPackager.new)
        gem_packager.build_from_source(@project_spec.name, Dir.pwd)
      end

    end
  end
end
