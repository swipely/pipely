require 'timecop'
require 'fog'
require 'rspec'
require 'vcr'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

Fog.credentials = {
  aws_access_key_id: "xxx",
  aws_secret_access_key: "xxx"
}

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
