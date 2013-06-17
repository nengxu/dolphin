# set up target servers
class Dolphin::Setup < Dolphin::Base

  desc "chruby", "install chruby"
  def chruby
    menu = [
      "
        # git clone
        if [ ! -d 'chruby' ]; then git clone https://github.com/postmodern/chruby.git ; fi
        # checkout tag
        cd chruby
        git checkout v0.3.5
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
  def ruby(version="2.0.0-p195")
    menu = [
      "
        # update ruby-build
        cd ruby-build
        git pull
        sudo ./install.sh
      ",
      "
        # install ruby
        sudo ruby-build #{version} /opt/rubies/ruby-#{version}
      ",
    ]

    execute menu
  end

  desc "select", "select ruby, arg: version"
  def select(version="2.0.0-p195")
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
        sudo gem install bundler
      ",
    ]

    execute menu
  end

end

