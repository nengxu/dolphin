# Dolphin

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'dolphin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dolphin

## Rails generator

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
    when 'production'
    else # @env == 'alpha'
      # list of servers for this environment
      @servers = [
        'prod01.best_app.com',
        'prod02.best_app.com',
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
    $ bin/dolphin loc
    $ bin/dolphin nginx
    $ bin/dolphin puma
    $ bin/dolphin setup

Execute a subcommand, for example, normal deployment:

    $ bin/dolphin deploy go -e production

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
