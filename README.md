# Dolphin

Dolphin: deploy agilely like dolphins can swim. A multi-threaded multi-stage deployment tool utilizes the full power of Git and Ruby.

* Bye bye, serial iteration over list of servers;
* Welcome, multi-threaded deployment using Parallel gem.
* Bye bye, afterthought of the multistage extension;
* Welcome, multi-stage deployment built in from inception.
* Bye bye, SVN style checkout directories on servers;
* Welcome, git repository on servers.
* Bye bye, Capistrano style symlink tricks for current / rollback;
* Welcome, git checkout.
* Bye bye, Rake tasks;
* Welcome, Thor actions.
* Bye bye, RVM;
* Welcome, Chruby.
* Bye bye, gemset;
* Welcome, system wide gems.
* Bye bye, complexity;
* Welcome, nimbleness.

## Installation / Rails generator

Add this line to your application's Gemfile:

    gem 'dolphin'

Or install it yourself as:

    $ gem install dolphin

Run generator from your Rails application:

    $ bin/rails g dolphin:install

This will create an executable script as bin/dolphin.

## Configuration

Edit the bin/dolphin script generated as above to adjust settings. Please refer to detailed comments inside the script. Minimum config would require the following:

    # settings require user input
    # -----------------------------
    # name of this application
    @application = 'best_app'
    # on server, the user account for deploying
    @user = 'deploy'
    # location of git repository
    @github = "git@github.com:nengxu/dolphin.git"
    # which ruby, for chruby
    @ruby_version = 'ruby-2.0.0-p195'

    case @env
    when 'qa'
      @servers = [
        'qa01.best_app.com',
        'qa02.best_app.com',
      ]
    when 'production'
      @servers = [
        'prod01.best_app.com',
        'prod02.best_app.com',
      ]
    else # @env == 'alpha'
      # list of servers for this environment
      @servers = [
        'dev01.best_app.com',
        'dev02.best_app.com',
      ]
      # customized branch, default is the same as @env
      @branch = 'master'
    end

## Usage

Show top level command modules:

    $ bin/dolphin

Show subcommands under one module:

    $ bin/dolphin deploy
    $ bin/dolphin git
    $ bin/dolphin lock
    $ bin/dolphin nginx
    $ bin/dolphin puma
    $ bin/dolphin setup

Execute a subcommand, for example, normal deployment:

    $ bin/dolphin deploy go -e production

## Extend with custom modules

To extend dolphin's functionality with your custom modules is easy. It is Ruby anyway. For example, to add Centos related functions:

    # bin/dolphin
    # adjust Centos config
    class Dolphin::Centos < Dolphin::Base
      desc "git", "install latest git"
      def git
        menu = [
          "
            # install rpmforge
            wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
            wget http://apt.sw.be/RPM-GPG-KEY.dag.txt
            sudo rpm --import RPM-GPG-KEY.dag.txt
            sudo rpm -K rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
            sudo rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
            sudo cp ~/rpmforge.repo /etc/yum.repos.d/

            # list repos
            # yum repolist

            # install git
            sudo yum -y remove git
            sudo yum clean all
            sudo yum -y update
            sudo yum -y install git
          ",
        ]

        execute menu
      end
    end

    class Dolphin::CLI < Thor
      register(Dolphin::Centos, 'centos', 'centos', 'Adjust Centos config')
    end

## Related gems

* [capistrano]
* [chruby]
* [git-deploy]
* [hell]
* [mina]
* [moonshine]
* [strano]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[capistrano]: https://github.com/capistrano/capistrano
[chruby]: https://github.com/postmodern/chruby
[git-deploy]: https://github.com/mislav/git-deploy
[hell]: https://github.com/seatgeek/hell
[mina]: https://github.com/nadarei/mina
[moonshine]: https://github.com/railsmachine/moonshine
[strano]: https://github.com/joelmoss/strano
