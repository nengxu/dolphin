# Puma related commands
class Dolphin::Puma < Dolphin::Base

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

