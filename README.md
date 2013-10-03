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

## Installation / Rails generators

### Installation

Add this line to your application's Gemfile:

    gem 'dolphin'

Or install it yourself as:

    $ gem install dolphin

### Generator for dolphin executable

Run generator from your Rails application:

    $ bin/rails g dolphin:install

This will create an executable script as bin/dolphin.

### Generator for Puma config

Run generator from your Rails application:

    $ bin/rails g dolphin:puma

This will create a config file for Puma as config/puma.rb.

## Configuration

### Config for dolphin executable

Edit the bin/dolphin script generated as above to adjust settings. Please refer to detailed comments inside the script. Minimum config would require the following:

    # settings require user input
    # -----------------------------
    # name of this application
    @application = 'best_app'
    # on server, the user account for deploying
    @user = 'deploy'
    # on server, the user group for deploying
    @user_group = 'deploy'
    # location of git repository
    @github = "git@github.com:nengxu/dolphin.git"

    case @env
    when 'qa'
      @server_hash = {
        q1: 'qa01.best_app.com',
        q2: 'qa02.best_app.com',
      }
    when 'production'
      @server_hash = {
        p1: 'prod01.best_app.com',
        p2: 'prod02.best_app.com',
      }
    else # @env == 'alpha'
      # list of servers for this environment
      @server_hash = {
        d1: 'dev01.best_app.com',
        d2: 'dev02.best_app.com',
      }
      # customized branch, default is the same as @env
      @branch = 'master'
    end

### Config for Puma

Edit the config/puma.rb script generated as above to adjust settings. Please refer to detailed comments inside the script. Minimum config would require the following:

    # settings require user input
    # -----------------------------
    # name of this application
    application = 'best_app'

You may also refer to Puma for explanation of options:
* [puma]

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

### Local mode

Dolphin can also be used to deploy to developer's local machine. Just pass the --local (or -l for short) option when issue command. By default, dolphin will log into localhost as yourself. You may also specify another user to log in as.

    # running in local mode
    if options[:local]
      # by default, log in as yourself
      @user = `whoami`.strip
      # may log in as another user
      # @user = 'neng'
      @servers = [
        'localhost',
      ]
    end

For example, you can start puma in production mode on your local machine:

    bin/dolphin puma start -e production -l

### Deploy to one specific server

Sometimes we need to take some actions on only one specific server. Just pass the --target (or -t for short) option when issue command. Notice that in @server_hash, we difine a key-value pair for each server. So we only need to pass the key for that specific server as the -t option.

    bin/dolphin nginx conf -t q2

Relevant settings in bin/dolphin are:

    case @env
    when 'qa'
      @server_hash = {
        q1: 'qa01.best_app.com',
        q2: 'qa02.best_app.com',
      }

    # apply to one target server
    if options[:target]
      @servers = [
        @server_hash[options[:target].to_sym],
      ]
    end

### Deploy to one specific group

Sometimes we need to take some actions on only one specific group, which may contains arbitrary number of servers. Just pass the --group (or -g for short) option when issue command. Notice that in @group_hash, we difine a key-value pair for each group. So we only need to pass the key for that specific group as the -g option.

    bin/dolphin mongo install -g mongo

Relevant settings in bin/dolphin are:

      @group_hash = {
        mongo: [:mongo1, :mongo2, :mongo3, ],
        java: [:graylog, :elasticsearch, ],
        app: [:app1, :app2, ],
      }

    # apply to one target group
    if options[:group]
      @servers = @group_hash[options[:group].to_sym].map {|item| @server_hash[item]}
    end

### Dry-run mode
Passing the --dry (or -d for short) option to enter dry-run mode.

    bin/dolphin deploy go -d

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

## Select Linux distribution specific modules
Dolphin contains some modules that are Linux distribution specific. For example, if you are using Ubuntu, you can include Ubuntu specific module by adding the following to bin/dolphin:

    require "dolphin/ubuntu/mongodb"

    class Dolphin::CLI < Thor
      register(Dolphin::Mongodb, 'mongodb', 'mongodb', 'MongoDB related tasks')
    end

## Related gems

* [capistrano]
* [chruby]
* [puma]
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
[puma]: https://github.com/puma/puma
[git-deploy]: https://github.com/mislav/git-deploy
[hell]: https://github.com/seatgeek/hell
[mina]: https://github.com/nadarei/mina
[moonshine]: https://github.com/railsmachine/moonshine
[strano]: https://github.com/joelmoss/strano
