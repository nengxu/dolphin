require_relative "dolphin/version"
require_relative "dolphin/base"
require_relative "dolphin/lock"
require_relative "dolphin/deploy"
require_relative "dolphin/setup"
require_relative "dolphin/nginx"
require_relative "dolphin/puma"

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
