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
        # install ruby
        # sudo /usr/local/bin/ruby-install #{version}
        /usr/local/bin/ruby-install #{version}
      ",
    ]

    execute menu
  end

  desc "rmrb", "remove ruby, arg: version, brand"
  def rmrb(version, brand='ruby')
    menu = [
      "
        # uninstall ruby
        # sudo rm -rf /opt/rubies/#{brand}-#{version}
        rm -rf ~/.rubies/#{brand}-#{version}
        # uninstall gems
        rm -rf ~/.gem/#{brand}/#{version}
      ",
    ]

    execute menu
  end

  desc "select", "select ruby, arg: dir, version"
  def select(dir=nil, version="ruby-2.1.5")
    dir ||= @app_dir
    menu = [
      "
        # select ruby
        cd #{dir}
        echo #{version} > .ruby-version
      ",
    ]

    execute menu
  end

  desc "gems", "install default gems, arg: ruby"
  def gems(ruby="ruby-2.1.5")
    menu = [
      %{
        cd #{@app_dir}
        # switch to the target ruby
        chruby #{ruby}
        # first gem-ctags so latter gems can be tagged
        gem install gem-ctags
        gem install bundler pry dolphin letters specific_install fled did_you_mean
      },
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

