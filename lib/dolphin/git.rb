# Git related commands
class Dolphin::Git < Dolphin::Base

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

