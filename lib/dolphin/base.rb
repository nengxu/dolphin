require "thor"
require 'net/ssh'
require 'parallel'

# core functions
class Dolphin::Base < Thor
  include Thor::Actions

# =============================================================================
# class options
# =============================================================================

  class_option :env, :aliases => '-e', :type => :string, :default => 'alpha'

  def initialize(args=[], options={}, config={})
    super(args, options, config)
    # set up environment
    env
  end

# =============================================================================
# private functions
# =============================================================================

  private

  # deployment environment
  def env
    # placeholder, to be implemented in each project

  end

  def parse_commands(menu)
    # Helper method to parse a list of text menu of possible commands,
    # which may contain empty lines or commented out with #
    # commands can be separated into groups

    commands = []
    menu.each do |group|
      buffer = []
      group.split(/\r?\n/).each do |line|
        line = line.strip
        unless line.empty? or line.start_with?('#') # empty or commented out
          buffer << line
        end
      end
      commands.push(*buffer)
    end
    commands
  end

  def ssh_connection(server)
    @sessions[server] ||= begin
      ssh = Net::SSH.start(server, @user, )
      at_exit { ssh.close }
      ssh
    end
  end

  def capture(command, server)
    output = ''
    session = ssh_connection(server)

    channel = session.open_channel do |chan|
      chan.exec(command) do |ch, success|

        ch.on_data do |c, data|
          output << data
        end

        ch.on_extended_data do |c, type, data|
          output << data
        end

      end
    end

    channel.wait
    output
  end

  def execute(menu)
    # execute commands defined in menu
    commands = parse_commands(menu)
    puts "#{'*'*10}Executing commands#{'*'*10}\n"
    commands.each do |command|
      puts "#{command}\n"
    end
    puts "#{'='*60}\n"

    # use Parallel to execute commands on multiple servers in parallel
    tracks = @servers.size
    # 3 threads maximum
    tracks = 3 if tracks > 3
    # record output to display at the end
    output = {}

    Parallel.map(@servers, in_threads: tracks) do |server|
      session = ssh_connection(server)
      output[server] = [] # output from this server

      channel = session.open_channel do |chan|
        chan.send_channel_request "shell" do |ch, success|
        # chan.request_pty do |ch, success|
          raise "could not start user shell" unless success

          # normal output
          ch.on_data do |c, data|
            msg = "[output]: #{data}"
            puts "#{server} => #{msg}"
            output[server] << msg
          end

          # error message
          ch.on_extended_data do |c, type, data|
            msg = "[error]: #{data}"
            puts "#{server} => #{msg}"
            output[server] << msg
          end

          # exit code
          ch.on_request "exit-status" do |c, data|
            msg = "[exit]: #{data.read_long}\n"
            puts "#{server} => #{msg}"
            output[server] << msg
          end

          # has to explicitly call shell startup script
          ch.send_data "source ~/.bash_profile\n"

          # pick up ruby
          ch.send_data "chruby #{@ruby_version}\n"

          # Output each command as if they were entered on the command line
          commands.each do |command|
            ch.send_data "#{command}\n"
          end

          # Remember to exit or we'll hang!
          ch.send_data "exit\n"

        end
      end

      # Wait for everything to complete
      channel.wait
    end

    # puts output
    puts "\n#{'*'*10}Results Review#{'*'*10}\n"
    output.each do |server, data|
      puts "\n#{'='*60}\n"
      puts "Executing on [#{server}] =>\n"
      data.each {|line| puts line}
    end
    puts "\n\n"
  end

end
