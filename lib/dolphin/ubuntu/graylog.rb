# graylog related tasks
class Dolphin::Graylog < Dolphin::Base

  desc "srvi", "install graylog2 server"
  def srvi
    menu = [
      %{
        wget https://github.com/Graylog2/graylog2-server/releases/download/0.13.0-rc.1/graylog2-server-0.13.0-rc.1.tar.gz
        tar xvfz graylog2-server-0.13.0-rc.1.tar.gz
        cd graylog2-server-0.13.0-rc.1
        sudo mv ~/graylog2-server-0.13.0-rc.1 /opt/graylog2-server
      },
    ]

    execute menu
  end

  desc "srvc", "config graylog2 server"
  def srvc
    # upload files
    upload("#{@config_root}/graylog/server/*", "/tmp")

    clustername = @env
    networkhost = @vpn_hash[:log]
    unicasthost = @vpn_hash[:ela]
    indexprefix = @env
    mongodbdatabase = "#{@env}-graylog2"
    mongodbreplicaset = @group_hash[:mg].map {|item| "#{@vpn_hash[item]}:27017"}.join(',')

    menu = [
      %{
        # sed -i 's/CLUSTERNAME/#{clustername}/' /tmp/graylog2-elasticsearch.yml
        sed -i 's/NETWORKHOST/#{networkhost}/' /tmp/graylog2-elasticsearch.yml
        sed -i 's/UNICASTHOST/#{unicasthost}/' /tmp/graylog2-elasticsearch.yml
        # sed -i 's/INDEXPREFIX/#{indexprefix}/' /tmp/graylog2.conf
        # sed -i 's/MONGODBREPLICASET/#{mongodbreplicaset}/' /tmp/graylog2.conf
        # sed -i 's/MONGODBDATABASE/#{mongodbdatabase}/' /tmp/graylog2.conf
        sudo mv /tmp/graylog2* /etc
        sudo chown root:root /etc/graylog2*
        sudo mv /tmp/graylog.conf /etc/init/
        sudo chown root:root /etc/init/graylog.conf
        sudo mv /tmp/rails.conf /etc/init/
        sudo chown root:root /etc/init/rails.conf
        sudo restart graylog
      },
    ]

    execute menu
  end

  desc "ufw", "config firewall"
  def ufw
    menu = [
      %{
        # graylog2
        sudo ufw allow from 192.168.0.0/16 to any port 514
        sudo ufw allow from 192.168.0.0/16 to any port 514
        sudo ufw allow from 192.168.0.0/16 to any port 12201

        # elasticsearch ports
        sudo ufw allow from 192.168.0.0/16 to any port 9200
        sudo ufw allow from 192.168.0.0/16 to any port 9300

        # nginx
        sudo ufw allow 'Nginx Full'
        sudo ufw status numbered
      },
    ]

    execute menu
  end

  desc "webi", "install graylog2 web interface"
  def webi
    menu = [
      %{
        # web interface
        sudo mkdir #{@app_dir}
        sudo chown #{@user}:#{@user_group} #{@app_dir}
        cd #{@app_dir}
        wget https://github.com/Graylog2/graylog2-web-interface/releases/download/0.12.0/graylog2-web-interface-0.12.0.tar.gz
        tar xvfz graylog2-web-interface-0.12.0.tar.gz
        mv graylog2-web-interface-0.12.0 graylog2
      },
    ]

    execute menu

    # manual steps
    %{
      bin/dolphin setup chruby -t log
      bin/dolphin setup ruby_install -t log
      bin/dolphin setup ruby -t log
      bin/dolphin setup select -t log
      bin/dolphin ubuntu user -t log
      bin/dolphin setup bundler -t log

      # add puma to Gemfile
      sudo bundle install
      # run rake secret
    }
  end

  desc "webc", "config graylog2 web interface"
  def webc
    # upload files
    upload("#{@config_root}/log/nginx/*", "/tmp/")

    servername = @server_hash[:log]
    menu = [
      %{
        # nginx
        sed -i 's/SERVERNAME/#{servername}/' /tmp/graylog2.conf
        sudo mv /tmp/graylog2.conf /etc/nginx/sites-available/
        sudo rm -f /etc/nginx/sites-enabled/default
        sudo ln -sf /etc/nginx/sites-available/graylog2.conf /etc/nginx/sites-enabled
      },
    ]

    execute menu

    upload("#{@config_root}/log/rails/*", "#{app_dir}/graylog2/config/")
  end

  desc "webb", "begin graylog2 web interface"
  def webb
    menu = [
      %{
        source /usr/local/share/chruby/chruby.sh
        source /usr/local/share/chruby/auto.sh
        cd #{@deploy_dir}
        RAILS_ENV=production bundle exec puma -C #{@deploy_dir}/config/puma.rb
      },
    ]

    execute menu
  end

  desc "webs", "stop graylog2 web interface"
  def webs
    menu = [
      %{
        source /usr/local/share/chruby/chruby.sh
        source /usr/local/share/chruby/auto.sh
        cd #{@deploy_dir}
        RAILS_ENV=production bundle exec pumactl -S #{@pids}/#{@application}.state stop
      },
    ]

    execute menu
  end

  desc "webr", "restart graylog2 web interface"
  def webr
    menu = [
      %{
        source /usr/local/share/chruby/chruby.sh
        source /usr/local/share/chruby/auto.sh
        cd #{@deploy_dir}
        RAILS_ENV=production bundle exec pumactl -S #{@pids}/#{@application}.state restart
      },
    ]

    execute menu
  end

  private

  # deployment environments
  def env
    # inherit general settings
    super

    # name of this application
    @application = 'graylog2'
    # on servers under @app_dir, the directory where this application resides
    @deploy_dir = "#{@app_dir}/#{@application}"
    # puma related settings
    @pids = "#{@deploy_dir}/tmp/pids"

    # ===================================
    # settings to avoid simultaneous deployments
    # ===================================

    # current deployment will abort when another deployment is still in progress

    # lead server for lock status
    @lead_server = @servers[0]
    # name and location of the lock file
    @lock_file = "#{@deploy_dir}/tmp/pids/dolphin.lock"
    # format of date/time for lock file
    @deploy_date = Time.now.strftime("%m%d%H%M")
    # custom content for the lock file
    @lock_message = "Deploy started at #{@deploy_date} in progress\n"
    # name and location of the head file to store git head info
    @head_file = "#{@deploy_dir}/tmp/pids/head.txt"
  end

end
