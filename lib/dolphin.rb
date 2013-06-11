require "thor"
require 'net/ssh'
require 'parallel'

require_relative "dolphin/version"

module Dolphin
  # core functions
  class Base < Thor
    include Thor::Actions

  # =============================================================================
  # class options
  # =============================================================================

    class_option :env, :aliases => '-e', :type => :string, :default => 'alpha'

    def initialize(args=[], options={}, config={})
      super(args, options, config)
      # set up environment
      env
    end

  # =============================================================================
  # private functions
  # =============================================================================

    private

    # deployment environment
    def env
      # placeholder, to be implemented in each project

    end

    def parse_commands(menu)
      # Helper method to parse a list of text menu of possible commands,
      # which may contain empty lines or commented out with #
      # commands can be separated into groups

      commands = []
      menu.each do |group|
        buffer = []
        group.split(/\r?\n/).each do |line|
          line = line.strip
          unless line.empty? or line.start_with?('#') # empty or commented out
            buffer << line
          end
        end
        commands.push(*buffer)
      end
      commands
    end

    def ssh_connection(server)
      @sessions[server] ||= begin
        ssh = Net::SSH.start(server, @user, )
        at_exit { ssh.close }
        ssh
      end
    end

    def run(menu)
      # execute commands defined in menu
      commands = parse_commands(menu)
      puts "#{'*'*10}Executing commands#{'*'*10}\n"
      commands.each do |command|
        puts "#{command}\n"
      end
      puts "#{'='*60}\n"

      # use Parallel to run commands on multiple servers in parallel
      tracks = @servers.size
      # 3 threads maximum
      tracks = 3 if tracks > 3
      # record output to display at the end
      output = {}

      Parallel.map(@servers, in_threads: tracks) do |server|
        session = ssh_connection(server)
        output[server] = [] # output from this server

        channel = session.open_channel do |chan|
          chan.send_channel_request "shell" do |ch, success|
          # chan.request_pty do |ch, success|
            raise "could not start user shell" unless success

            # normal output
            ch.on_data do |c, data|
              msg = "[output]: #{data}"
              puts "#{server} => #{msg}"
              output[server] << msg
            end

            # error message
            ch.on_extended_data do |c, type, data|
              msg = "[error]: #{data}"
              puts "#{server} => #{msg}"
              output[server] << msg
            end

            # exit code
            ch.on_request "exit-status" do |c, data|
              msg = "[exit]: #{data.read_long}\n"
              puts "#{server} => #{msg}"
              output[server] << msg
            end

            # has to explicitly call shell startup script
            ch.send_data "source ~/.bash_profile\n"

            # pick up ruby
            ch.send_data "chruby #{@ruby_version}\n"

            # Output each command as if they were entered on the command line
            commands.each do |command|
              ch.send_data "#{command}\n"
            end

            # Remember to exit or we'll hang!
            ch.send_data "exit\n"

          end
        end

        # Wait for everything to complete
        channel.wait
      end

      # puts output
      puts "\n#{'*'*10}Results Review#{'*'*10}\n"
      output.each do |server, data|
        puts "\n#{'='*60}\n"
        puts "Executing on [#{server}] =>\n"
        data.each {|line| puts line}
      end
      puts "\n\n"
    end

  end

  # =============================================================================
  # Setup
  # =============================================================================
  class Setup < Base
    desc "chruby", "install chruby"
    def chruby
      menu = [
        "
          # git clone
          if [ ! -d 'chruby' ]; then git clone https://github.com/postmodern/chruby.git ; fi
          # checkout tag
          cd chruby
          git checkout v0.3.5
          # install
          sudo make install
        ",
      ]

      run menu
    end

    desc "repo", "repository set up."
    def repo
      menu = [
        "
          # init git repository
          cd #{@app_dir}
          git clone #{@github}
        ",
        "
          # set up tracking branch
          cd #{@deploy_dir}
          git checkout -b #{@branch} origin/#{@branch}
        ",
      ]

      run menu
    end

    desc "ruby", "install ruby, arg: version"
    def ruby(version="2.0.0-p195")
      menu = [
        "
          # update ruby-build
          cd ruby-build
          git pull
          sudo ./install.sh
        ",
        "
          # install ruby
          sudo ruby-build #{version} /opt/rubies/ruby-#{version}
        ",
      ]

      run menu
    end

    desc "select", "select ruby, arg: version"
    def select(version="2.0.0-p195")
      menu = [
        "
          # select ruby
          cd #{@app_dir}
          echo ruby-#{version} > .ruby-version
        ",
      ]

      run menu
    end

    desc "bundler", "install bundler"
    def bundler
      menu = [
        "
          # install bundler
          sudo gem install bundler
        ",
      ]

      run menu
    end

    desc "rvm", "remove rvm"
    def rvm
      menu = [
        "
          sudo yum -y remove move-rvm
          sudo rm -rf /usr/local/rvm
        ",
      ]

      run menu
    end

    desc "apache", "remove apache"
    def apache
      menu = [
        "
          sudo chkconfig httpd.newhomesapi off
          sudo chkconfig httpd.newhomesrdc off
          sudo yum -y remove httpd
        ",
      ]

      run menu
    end

    desc "git", "install latest git"
    def git
      menu = [
        "
          # install rpmforge
          wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
          wget http://apt.sw.be/RPM-GPG-KEY.dag.txt
          sudo rpm --import RPM-GPG-KEY.dag.txt
          sudo rpm -K rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
          sudo rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
          sudo cp ~/rpmforge.repo /etc/yum.repos.d/

          # list repos
          # yum repolist

          # install git
          sudo yum -y remove git
          sudo yum clean all
          sudo yum -y update
          sudo yum -y install git
        ",
      ]

      run menu
    end

  end

  # =============================================================================
  # Nginx
  # =============================================================================
  class Nginx < Base
    desc "install", "install nginx"
    def install
      menu = [
        "
          # set repo
          sudo cp ~/nginx.repo /etc/yum.repos.d/

          # list repos
          # yum repolist

          # install nginx
          sudo yum -y install nginx
        ",
      ]

      run menu
    end

    desc "conf", "config nginx"
    def conf
      menu = [
        "
          sudo ln -sf #{@deploy_dir}/config/nginx/#{@application}.conf /etc/nginx/conf.d/#{@application}.conf
        ",
      ]

      run menu
    end

    desc "start", "start nginx"
    def start
      menu = [
        "
          # common settings
          sudo service nginx start
        ",
      ]

      run menu
    end

    desc "stop", "stop nginx"
    def stop
      menu = [
        "
          # common settings
          sudo service nginx stop
        ",
      ]

      run menu
    end

    desc "restart", "restart nginx"
    def restart
      menu = [
        "
          # common settings
          sudo service nginx restart
        ",
      ]

      run menu
    end

  end

  # =============================================================================
  # Deploy
  # =============================================================================
  class Deploy < Base
    desc "bundle", "sudo bundle install"
    def bundle
      menu = [
        "
          cd #{@deploy_dir}
          sudo bundle install --quiet
        ",
      ]

      run menu
    end

    desc "go", "normal deploy procedure"
    def go
      # update code
      invoke "dolphin:git:update"

      # no need to invoke since it is within the same class
      bundle

      # restart app server
      invoke "dolphin:puma:restart"
    end

    desc "try", "normal deploy procedure"
    def try
      menu = [
        "
          cd #{@deploy_dir}
          pwd
          bundle check
        ",
      ]

      run menu
    end

  end

  # =============================================================================
  # Git
  # =============================================================================
  class Git < Base
    desc "update", "Update code from github and keep local changes"
    def update
      menu = [
        "
          cd #{@deploy_dir}
          git fetch
          git stash
          git checkout #{@branch}
          git rebase origin/#{@branch}
          git stash apply
          git stash clear
        ",
      ]

      run menu
    end

  end

  # =============================================================================
  # Puma
  # =============================================================================
  class Puma < Base
    desc "start", "start puma"
    def start
      menu = [
        "
          cd #{@deploy_dir}
          RAILS_ENV=#{@env} bundle exec puma -t 8:32 -e #{@env} -d -b unix://#{@sockets}/#{@application}.sock -S #{@pids}/#{@application}.state --control unix://#{@sockets}/pumactl.sock --pidfile #{@pids}/#{@application}.pid
        ",
      ]

      run menu
    end

    desc "stop", "stop puma"
    def stop
      menu = [
        "
          cd #{@deploy_dir}
          RAILS_ENV=#{@env} bundle exec pumactl -S #{@pids}/#{@application}.state stop
        ",
      ]

      run menu
    end

    desc "restart", "restart puma"
    def restart
      menu = [
        "
          cd #{@deploy_dir}
          # RAILS_ENV=#{@env} bundle exec pumactl -S #{@pids}/#{@application}.state restart
          kill -s SIGUSR2 `cat #{@pids}/#{@application}.pid`
        ",
      ]

      run menu
    end

  end

  # =============================================================================
  # CLI
  # =============================================================================
  class CLI < Thor
    register(Setup, 'setup', 'setup', 'set up target server')
    register(Deploy, 'deploy', 'deploy', 'deploy to target server')
    register(Puma, 'puma', 'puma', 'Puma related commands')
    register(Nginx, 'nginx', 'nginx', 'Nginx related commands')
    register(Git, 'git', 'git', 'Git related commands')
  end

end
