# Mongodb related tasks
class Dolphin::Mongodb < Dolphin::Base

  desc "install", "install mongodb"
  def install
    menu = [
      "
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
        sudo echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
        sudo apt-get update
        sudo apt-get -y install mongodb-10gen
      ",
    ]

    execute menu
  end

  desc "disable", "disable mongodb"
  def disable
    menu = [
      "
        sudo sh -c 'echo manual > /etc/init/mongodb.override'
      ",
    ]

    execute menu
  end

  desc "enable", "enable mongodb"
  def enable
    menu = [
      "
        sudo rm -f /etc/init/mongodb.override
        sudo start mongodb
      ",
    ]

    execute menu
  end

  desc "config", "config mongodb"
  def config
    # upload files
    upload("#{@config_root}/mongo/*", "/tmp")

    # allow access from peers
    ufw = [
      '# ufw',
      'sudo ufw allow from 192.168.0.0/16 to any port 27017',
      'sudo ufw allow from 192.168.0.0/16 to any port 28017',
    ]
    @group_hash[:mg].each do |item|
      ufw << "sudo ufw allow from #{@server_hash[item]}/32 to any port 27017"
      ufw << "sudo ufw allow from #{@server_hash[item]}/32 to any port 28017"
    end
    ufw << "sudo ufw status numbered"

    menu = [
      ufw.join("\n"),

      # allow world access
      %{
        sudo ufw allow from any to any port 27017
        sudo ufw allow from any to any port 28017
      },

      # config files
      %{
        sudo mv /tmp/mongodb.conf /etc/
        sudo chown root:root /etc/mongodb.conf
        sudo mv /tmp/keyfile.txt /etc/
        sudo chown mongodb:mongodb /etc/keyfile.txt
        sudo chmod go-r /etc/keyfile.txt
        sudo restart mongodb
      },

    ]

    execute menu

  end

  desc "backup", "backup mongodb"
  def backup
    # upload files
    upload("#{@config_root}/mongo/*", "/tmp")

    menu = [
      %{
        mkdir -p ~/backups/mongodb
        mv /tmp/mg* ~/backups/mongodb
        # # add cron job to /var/spool/cron/crontabs/vidi
        crontab /tmp/vidi
      },

    ]

    execute menu
  end

end
