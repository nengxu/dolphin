# Nginx related commands
class Dolphin::Nginx < Dolphin::Base

  desc "install", "install nginx"
  def install
    menu = [
      "
        # set repo
        sudo cp ~/nginx.repo /etc/yum.repos.d/

        # list repos
        # yum repolist

        # install nginx
        sudo yum -y install nginx
      ",
    ]

    execute menu
  end

  desc "conf", "config nginx"
  def conf
    menu = [
      "
        sudo ln -sf #{@deploy_dir}/config/nginx/#{@application}.conf /etc/nginx/conf.d/#{@application}.conf
      ",
    ]

    execute menu
  end

  desc "start", "start nginx"
  def start
    menu = [
      "
        # common settings
        sudo service nginx start
      ",
    ]

    execute menu
  end

  desc "stop", "stop nginx"
  def stop
    menu = [
      "
        # common settings
        sudo service nginx stop
      ",
    ]

    execute menu
  end

  desc "restart", "restart nginx"
  def restart
    menu = [
      "
        # common settings
        sudo service nginx restart
      ",
    ]

    execute menu
  end

end

