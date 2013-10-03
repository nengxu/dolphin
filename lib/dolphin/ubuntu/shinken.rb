# shinken related tasks
class Dolphin::Shinken < Dolphin::Base

  desc "client", "shinken client config"
  def client
    # upload files
    upload("#{@config_root}/shinken/client/*", "/tmp")

    menu = [
      %{
       # sudo apt-get -y install snmpd
       sudo mv /tmp/snmpd.conf /etc/snmp/
       sudo chown root:root /etc/snmp/snmpd.conf
       sudo service snmpd restart

      },
    ]

    execute menu
  end

  desc "install", "install shinken server"
  def install
    menu = [
      %{
        wget http://www.shinken-monitoring.org/pub/shinken-1.4.tar.gz
        tar -xvzf shinken-1.4.tar.gz
        cd ~/shinken-1.4
        sudo ./install -i

        sudo ./install -h
        sudo ./install -p nagios-plugins
        sudo ./install -p check_mem
        sudo ./install -p manubulon
        sudo ./install -p check_snmp_bandwidth
        sudo ./install -p check_snmp
        sudo ./install -p check_netint
        sudo ./install -p check_mongodb

        sudo apt-get -y install nagios-plugins
        # sudo ./install -a pnp4nagios
        # sudo ./install -a mongodb # already installed

        sudo update-rc.d mongodb enable
      },
    ]

    execute menu
  end

  desc "config", "config shinken server"
  def config
    # template: etc/packs/os/linux
    # upload files
    upload("#{@config_root}/shinken/server/*", "/tmp")

    menu = [
      %{
        sudo mv /tmp/nagios.cfg /usr/local/shinken/etc/
        sudo mv /tmp/shinken-specific.cfg /usr/local/shinken/etc/
        sudo mv /tmp/resource.cfg /usr/local/shinken/etc/
        sudo mv /tmp/contacts.cfg /usr/local/shinken/etc/
        sudo mv /tmp/commands.cfg /usr/local/shinken/etc/
        sudo mv /tmp/templates.cfg /usr/local/shinken/etc/
        sudo mv /tmp/staging.cfg /usr/local/shinken/etc/hosts/
        sudo mv /tmp/production.cfg /usr/local/shinken/etc/hosts/
        sudo mv /tmp/services.cfg /usr/local/shinken/etc/hosts/
        sudo service shinken restart
      },

    ]

    execute menu
  end

  desc "email", "install email client"
  def email
    menu = [
      %{
        sudo apt-get -y install libio-socket-ssl-perl libdigest-hmac-perl libterm-readkey-perl libmime-lite-perl libfile-libmagic-perl libio-socket-inet6-perl
        sudo chown #{@user}:#{@user_group} #{@app_dir}
        cd #{@app_dir}
        if [ ! -d 'smtp-cli' ]; then git clone https://github.com/mludvig/smtp-cli.git ; fi
      },
    ]

    execute menu
  end

end
