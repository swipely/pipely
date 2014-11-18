
module Pipely
  module Deploy

    # Context passed to the erb templates, providers helpers for
    # common bootstraping activities for emr and ec2 instances.
    #
    #   bootstrap.ec2.install_gems_script
    #   bootstrap.emr.install_gems_script
    #
    class BootstrapContext
      attr_accessor :gem_files, :s3_steps_path
      attr_reader :ec2, :emr

      # Context for EMR instances
      class EmrContext
        def initialize(parent)
          @parent = parent
        end

        def install_gems_script(&blk)
          @parent.install_gems_script(:hadoop_fs, &blk)
        end
      end

      # Context for EC2 instances
      class Ec2Context
        def initialize(parent)
          @parent = parent
          @ssh_initialized = false
        end

        def install_gems_script(&blk)
          @parent.install_gems_script(:awscli, &blk)
        end

        def as_root(init_ssh=true)
          script = ""

          if init_ssh && !@ssh_initialized
            @ssh_initialized = true
            script << %{
# Set up ssh access
if [ ! -f ~/.ssh/id_rsa ]; then
  mkdir -p ~/.ssh
  ssh-keygen -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
fi
}
          end

          script << %{
# Use ssh to bypass the sudo "require tty" setting
ssh -o "StrictHostKeyChecking no" -t -t ec2-user@localhost <<- EOF
  sudo su -;
}

          # The yield to be run as root
          script << yield

          script << %{
  # exit twice, once for su and once for ssh
  exit;
  exit;
EOF
}
        end
      end

      def initialize
        @emr = EmrContext.new(self)
        @ec2 = Ec2Context.new(self)
      end

      def fetch_command(transport)
        case transport.to_sym
        when :hadoop_fs
          'hadoop fs -copyToLocal'
        when :awscli
          'aws s3 cp'
        end
      end

      def install_gems_script(transport, &blk)

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
