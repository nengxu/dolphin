# Use lock to avoid simultaneous deployments
class Dolphin::Lock < Dolphin::Base

  desc "check", "Check lock"
  def check
    command = "if [ -e #{@lock_file} ]; then cat #{@lock_file}; fi"
    output = capture(command, @lead_server)
    if output.empty?
      puts "OK to proceed"
    else
      puts "[output]: #{output}"
      abort "\e[0;31m A deployment is already in progress\n Please wait for its completion\nOr in case of stale lock, remove #{@lock_file} to unlock \e[0m\n"
    end
  end

  desc "create", "Create lock"
  def create
    command = "echo '#{@lock_message}' > #{@lock_file}"
    puts capture(command, @lead_server)
  end

  desc "release", "Release lock"
  def release
    command = "rm -f #{@lock_file}"
    puts capture(command, @lead_server)
  end

end
