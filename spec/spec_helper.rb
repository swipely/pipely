require 'timecop'
require 'fog'

Fog.credentials = {
  aws_access_key_id: "xxx",
  aws_secret_access_key: "xxx"
}

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
