# set up target servers
class Dolphin::Setup < Dolphin::Base

  desc "chruby", "install chruby"
  def chruby
    menu = [
      "
        # git clone
        if [ ! -d 'chruby' ]; then git clone https://github.com/postmodern/chruby.git ; fi
        cd chruby
        # update
        git fetch
        # checkout tag
        git checkout v0.3.6
        # install
        sudo make install
      ",
    ]

    execute menu
  end

  desc "ruby_install", "update ruby_install"
  def ruby_install(version='master')
    menu = [
      "
        # git clone
        if [ ! -d 'ruby-install' ]; then git clone https://github.com/postmodern/ruby-install.git ; fi
        cd ruby-install
        # update
        git fetch
        # checkout tag
        git checkout #{version}
        # install
        sudo make install
      ",
    ]

    execute menu
  end

  desc "repo", "repository set up."
  def repo
    menu = [
      "
        # init git repository
        cd #{@app_dir}
        git clone #{@github}
      ",
      "
        # set up tracking branch
        cd #{@deploy_dir}
        git checkout -b #{@branch} origin/#{@branch}
      ",
    ]

    execute menu
  end

  desc "ruby", "install ruby, arg: version"
  def ruby(version="2.0.0-p247")
    menu = [
      "
        # install ruby
        sudo ruby-install ruby #{version}
      ",
    ]

    execute menu
  end

  desc "select", "select ruby, arg: version"
  def select(version="2.0.0-p247")
    menu = [
      "
        # select ruby
        cd #{@app_dir}
        echo ruby-#{version} > .ruby-version
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
        sudo gem install bundler
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

