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

### Help

Show top level modules:

    $ bin/dolphin

Show tasks under one module:

    $ bin/dolphin deploy
    $ bin/dolphin git
    $ bin/dolphin lock
    $ bin/dolphin nginx
    $ bin/dolphin puma
    $ bin/dolphin setup

### Execute a task

Each task may involve running groups of commands on the servers. So the hierarchy is like:

    Module (eg., deploy / setup)
      Task (eg., go / rollback)
        Group (eg., check lock / update code / restart app)
          Commands (eg., git fetch / git rebase)

Generally run a task in this format:

    $ bin/dolphin module task argument1 argument2 -e option1 -o option2

For example, normal deployment to production:

    $ bin/dolphin deploy go -e production

Rollback to previous release in qa environment:

    $ bin/dolphin deploy rollback -e qa

Switch to a specific tag / branch / commit in alpha environment:

    $ bin/dolphin deploy rollback 96820cf

Please note that the default environment is alpha for developers. So there is no need to append "-e alpha" in the above example.

If you want to run a task locally on your own box, just set up a :local environment and put 'localhost' into @servers, like in the generated bin/dolphin. Then you can run the task like:

    $ bin/dolphin setup chruby -e local

### Output

The outputs from servers are captured and shown on your console as in the following sections.

#### Commands section
In this section, the list of commands from the current group is printed. For example:

    $ bin/dolphin deploy try
    **********Executing commands**********
    cd /rails/best_app
    pwd
    bundle check
    ============================================================

#### Capture section

In this section, the outputs from the servers are captured in realtime as they are generated. The outputs are classied in 3 types: output / error / exit. The general format of the captured output is:

    server.name => [type]: result from server

Because Dolphin is running tasks on servers in multi-threaded mode, outputs from all servers are mingled together like in random order. For example:

    dev01.best_app.com => [output]: /rails/best_app
    dev02.best_app.com => [output]: /rails/best_app
    dev02.best_app.com => [output]: The Gemfile's dependencies are satisfied
    dev02.best_app.com => [exit]: 0
    dev01.best_app.com => [output]: The Gemfile's dependencies are satisfied
    dev01.best_app.com => [exit]: 0

Caveat! Some server applications may label their output differently than expected. So if you see some output labelled with [error], don't assume there are errors or the commands failed. For example, Git may produce such:

    dev02.best_app.com => [error]: Note: checking out '96820cffcec43499acfc737bade544aa011f5376'.

    You are in 'detached HEAD' state. You can look around, make experimental
    changes and commit them, and you can discard any commits you make in this
    state without impacting any branches by performing another checkout.

    If you want to create a new branch to retain commits you create, you may
    do so (now or later) by using -b with the checkout command again. Example:

      git checkout -b new_branch_name

    dev02.best_app.com => [error]: HEAD is now at 96820cf... Return format from gem changed.
    dev02.best_app.com => [exit]: 0

#### Review section

In this section, the outputs from current command group are printed out again. However, outputs from the same server are grouped together. So you can review the results server by server.

    **********Results Review**********

    ============================================================
    Executing on [dev01.best_app.com] =>
    [output]: /rails/best_app
    [output]: The Gemfile's dependencies are satisfied
    [exit]: 0

    ============================================================
    Executing on [dev02.best_app.com] =>
    [output]: /rails/best_app
    [output]: The Gemfile's dependencies are satisfied
    [exit]: 0

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
