require_relative "dolphin/version"
require_relative "dolphin/base"
require_relative "dolphin/lock"
require_relative "dolphin/deploy"
require_relative "dolphin/setup"
require_relative "dolphin/nginx"

module Dolphin

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
