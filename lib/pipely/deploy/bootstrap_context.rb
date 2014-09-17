
module Pipely
  module Deploy

    # Context passed to the erb templates
    class BootstrapContext
      attr_accessor :gem_files
      attr_accessor :s3_steps_path

      def install_gems_script(transport = :hadoop_fs, &blk)
        script = ""

        case transport.to_sym
        when :hadoop_fs
          transport_cmd = 'hadoop fs -copyToLocal'
        when :awscli
          transport_cmd = 'aws s3 cp'
        else
          raise "Unsupported transport: #{transport}" unless blk
        end

        @gem_files.each do |gem_file|
          filename = File.basename(gem_file)
          command = "#{transport_cmd} #{gem_file} #{filename}" if transport_cmd
          command = yield(gem_file, filename, command) if blk
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
