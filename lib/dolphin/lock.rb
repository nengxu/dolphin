# Use lock to avoid simultaneous deployments
class Dolphin::Lock < Dolphin::Base

  desc "check", "Check lock"
  def check
    command = "if [ -e #{@lock_file} ]; then echo 'true'; fi"
    if 'true' ==  capture(command, @lead_server).strip
      abort "\n\n\n\e[0;31m A deployment is already in progress\n Please wait for its completion\nOr in case of stale lock, remove #{@lock_file} to unlock \e[0m\n\n\n"
    else
      puts "OK to proceed"
    end
  end

  desc "create", "Create lock"
  def create
    lock_message = "Deploy started at #{@deploy_date} in progress\n"
    menu = [
      "
        cd #{@app_dir}
        echo '#{lock_message}' > #{@lock_file}
        cat #{@lock_file}
      ",
    ]

    execute menu, @lead_server
  end

  desc "release", "Release lock"
  def release
    command = "rm -f #{@lock_file}"
    puts capture(command, @lead_server)
  end

end
