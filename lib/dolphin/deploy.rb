# Deploy tasks
class Dolphin::Deploy < Dolphin::Base

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
    # check lock
    invoke "dolphin:lock:check"
    # put lock
    invoke "dolphin:lock:create"

    # update code
    invoke "dolphin:git:update"

    # no need to invoke since it is within the same class
    bundle

    # restart app server
    invoke "dolphin:puma:restart"

    # remove lock
    invoke "dolphin:lock:release"
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
