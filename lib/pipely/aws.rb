require 'aws'

module Pipely
  # Helper for usine AWS SDK
  module Aws
    extend self

    # local credentials
    file_provider =
      ::AWS::Core::CredentialProviders::SharedCredentialFileProvider.new

    # Use IAM provider if no local creds
    unless File.exists? file_provider.path
      ::AWS.config(
        :credential_provider => AWS::Core::CredentialProviders::EC2Provider.new)
    end

    def S3
      ::AWS::S3.new
    end
  end
end
