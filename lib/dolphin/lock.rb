# Lock resource to avoid simultaneous deployments
class Dolphin::Lock < Dolphin::Base

  desc "check", "Check lock"
  def check
    command = "if [ -e #{@lock_file} ]; then echo 'true'; fi"
    if 'true' ==  capture(command, @lead_server).strip
      puts "\n\n\n\e[0;31m A deployment is already in progress\n Please wait for its completion\nOr in case of stale lock, remove #{@lock_file} to unlock \e[0m\n\n\n"
    else
      puts "ok to proceed"
    end

  end

end
