require_relative "dolphin/version"
require_relative "dolphin/base"

module Dolphin

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

      execute menu
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

      execute menu
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

      execute menu
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

      execute menu
    end

    desc "bundler", "install bundler"
    def bundler
      menu = [
        "
          # install bundler
          sudo gem install bundler
        ",
      ]

      execute menu
    end

    desc "rvm", "remove rvm"
    def rvm
      menu = [
        "
          sudo yum -y remove move-rvm
          sudo rm -rf /usr/local/rvm
        ",
      ]

      execute menu
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

      execute menu
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

      execute menu
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

      execute menu
    end

    desc "conf", "config nginx"
    def conf
      menu = [
        "
          sudo ln -sf #{@deploy_dir}/config/nginx/#{@application}.conf /etc/nginx/conf.d/#{@application}.conf
        ",
      ]

      execute menu
    end

    desc "start", "start nginx"
    def start
      menu = [
        "
          # common settings
          sudo service nginx start
        ",
      ]

      execute menu
    end

    desc "stop", "stop nginx"
    def stop
      menu = [
        "
          # common settings
          sudo service nginx stop
        ",
      ]

      execute menu
    end

    desc "restart", "restart nginx"
    def restart
      menu = [
        "
          # common settings
          sudo service nginx restart
        ",
      ]

      execute menu
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

      execute menu
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

      execute menu
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

      execute menu
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

      execute menu
    end

    desc "stop", "stop puma"
    def stop
      menu = [
        "
          cd #{@deploy_dir}
          RAILS_ENV=#{@env} bundle exec pumactl -S #{@pids}/#{@application}.state stop
        ",
      ]

      execute menu
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

      execute menu
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
