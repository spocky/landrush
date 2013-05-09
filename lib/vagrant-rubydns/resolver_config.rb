require 'tempfile'

module VagrantRubydns
  class ResolverConfig
    def self.desired_contents; <<-EOS.gsub(/^      /, '')
      # Generated by vagrant-rubydns
      nameserver 127.0.0.1
      port 10053
      EOS
    end

    def self.osx?
      `uname`.chomp == 'Darwin'
    end

    def self.config_file
      Pathname('/etc/resolver/vagrant.dev')
    end

    def self.contents_match?
      config_file.exist? && File.read(config_file) == desired_contents
    end

    def self.write_config
      puts "Mometarily using sudo to put the host config in place..."
      Tempfile.open('vagrant_rubydns_host_config') do |f|
        f.write(desired_contents)
        f.close
        `sudo cp #{f.path} /etc/resolver/vagrant.dev`
        `sudo chown root:wheel /etc/resolver/vagrant.dev`
        `sudo chmod 644 /etc/resolver/vagrant.dev`
      end
    end

    def self.ensure_config_exists
      unless osx?
        puts "Not an OSX machine, so skipping host DNS resolver config."
        return
      end

      if contents_match?
        puts "Host DNS resolver config looks good."
      else
        puts "Need to configure the host."
        write_config
      end
    end

    def self.puts(str)
      Kernel.puts("[vagrant-rubydns] #{str}")
    end
  end
end