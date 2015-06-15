require 'timecop'
require 'aws-sdk'
require 'rspec'
require 'vcr'
require 'pry'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new('xxx', 'xxx'),
})

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

class WebMock::StubSocket
  attr_accessor :continue_timeout, :read_timeout

  def closed?
    true
  end
end
