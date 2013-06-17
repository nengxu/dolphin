require_relative "dolphin/version"
require_relative "dolphin/base"
require_relative "dolphin/lock"
require_relative "dolphin/deploy"
require_relative "dolphin/setup"

module Dolphin

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
    register(Setup, 'setup', 'setup', 'Set up target servers')
    register(Deploy, 'deploy', 'deploy', 'Deploy to target server')
    register(Puma, 'puma', 'puma', 'Puma related commands')
    register(Nginx, 'nginx', 'nginx', 'Nginx related commands')
    register(Git, 'git', 'git', 'Git related commands')
    register(Lock, 'lock', 'lock', 'Lock resource to avoid simultaneous deployments')
  end

end
