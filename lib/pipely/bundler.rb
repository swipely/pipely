require 'pipely/bundler/bundle'
require 'pipely/bundler/gem_packager'
require 'pipely/bundler/project_gem'

module Pipely

  #
  # Module for packaging up a gem project and its dependencies, as they exist
  # on your machine, for deployment.
  #
  # None of this code is specific to AWS Data Pipelines, and it could be used
  # anywhere else you want to an in-development gem with frozen dependencies.
  #
  module Bundler

    # List all the gems used in this project in the format:
    #
    #   { name => path_to_cache_file }
    #
    # For gems that are git- or path-sourced, it will first build a fresh cache
    # file for the gem.
    #
    def self.gem_files(vendor_dir='vendor/pipeline')
      ProjectGem.load(vendor_dir).gem_files
    end

  end

end
