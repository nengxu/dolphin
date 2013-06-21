# Git related commands
class Dolphin::Git < Dolphin::Base

  desc "update", "Update code from github and keep local changes"
  def update
    menu = [
      "
        cd #{@deploy_dir}
        # Save git head info
        git rev-parse HEAD > #{@head_file}
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

  desc "checkout", "Checkout a specific tag, assume the code on server is up to date"
  def checkout(tag=nil)
    if tag
      command = "git checkout #{tag}"
    else
      command = "git checkout `cat #{@head_file}`"
    end
    menu = [
      "
        cd #{@deploy_dir}
        #{command}
      ",
    ]

    execute menu
  end

end

