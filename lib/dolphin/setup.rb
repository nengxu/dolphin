# set up target servers
class Dolphin::Setup < Dolphin::Base

  desc "chruby", "install/update chruby"
  def chruby(version='v0.3.8')
    menu = [
      "
        # git clone
        if [ ! -d 'chruby' ]; then git clone https://github.com/postmodern/chruby.git ; fi
        cd chruby
        # update
        git fetch
        git checkout master
        git rebase origin/master
        # checkout tag
        # git checkout #{version}
        # install
        sudo make install
        # system wise
        # sudo echo '[ -n \"$BASH_VERSION\" ] || [ -n \"$ZSH_VERSION\" ] || return' | sudo tee /etc/profile.d/chruby.sh
        # sudo echo 'source /usr/local/share/chruby/chruby.sh' | sudo tee -a /etc/profile.d/chruby.sh
      ",
    ]

    execute menu
  end

  desc "app_dir", "set up app dir"
  def app_dir
    menu = [
      "
        sudo mkdir -p #{@app_dir}
        sudo chown #{@user}:#{@user_group} #{@app_dir}
      ",
    ]

    execute menu
  end

  desc "ruby_install", "install/update ruby_install"
  def ruby_install(version='master')
    menu = [
      "
        # git clone
        if [ ! -d 'ruby-install' ]; then git clone https://github.com/postmodern/ruby-install.git ; fi
        cd ruby-install
        # update
        git fetch
        git checkout master
        git rebase origin/master
        # checkout tag
        # git checkout #{version}
        # install
        sudo make install
      ",
    ]

    execute menu
  end

  desc "repo", "repository set up."
  def repo
    # branch 'master' is always created by git
    if @branch == 'master'
      cmd = "git checkout master"
    else
      cmd = "git checkout -b #{@branch} origin/#{@branch}"
    end

    menu = [
      "
        # init git repository
        cd #{@app_dir}
        git clone #{@github}
      ",
      "
        # set up tracking branch
        cd #{@deploy_dir}
        #{cmd}
      ",
    ]

    execute menu
  end

  desc "ruby", "install ruby, arg: version"
  def ruby(version="ruby")
    menu = [
      "
        # intall gem system wise
        # sudo gem install bundler --no-user-install
        # install ruby
        sudo /usr/local/bin/ruby-install #{version}
      ",
    ]

    execute menu
  end

  desc "select", "select ruby, arg: version"
  def select(version="rubinius-2.1.1")
    menu = [
      "
        # select ruby
        cd #{@app_dir}
        echo #{version} > .ruby-version
      ",
    ]

    execute menu
  end

  desc "bundler", "install bundler"
  def bundler
    menu = [
      "
        # install bundler
        cd #{@app_dir}
        gem install bundler
      ",
    ]

    execute menu
  end

  desc "newrelic", "install newrelic agent"
  def newrelic
    menu = [
      "
        # install bundler
        sudo rpm -Uvh http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm
        sudo yum -y install newrelic-sysmond
        sudo nrsysmond-config --set license_key=c55d35d552a49f06d5183c95d41de60cd9754237
      ",
    ]

    execute menu
  end

end

