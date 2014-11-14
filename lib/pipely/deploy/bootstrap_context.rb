
module Pipely
  module Deploy

    # Context passed to the erb templates
    class BootstrapContext
      attr_accessor :gem_files
      attr_accessor :s3_steps_path

      def fetch_command(transport = :hadoop_fs)
        case transport.to_sym
        when :hadoop_fs
          'hadoop fs -copyToLocal'
        when :awscli
          'aws s3 cp'
        end
      end

      def install_gems_script(transport = :hadoop_fs, &blk)

        transport_cmd = fetch_command(transport)

        if transport_cmd.nil?
          raise "Unsupported transport: #{transport}" unless blk
        end

        script = ""
        @gem_files.each do |gem_file|
          filename = File.basename(gem_file)
          params = [transport_cmd, gem_file, filename]
          if blk
            command = yield(*params)
          else
            command = params.join(" ")
          end

          script << %Q[
# #{filename}
#{command}
gem install --force --local #{filename} --no-ri --no-rdoc
]
        end

        script
      end
    end
  end
end
