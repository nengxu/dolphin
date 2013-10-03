require "thor"
require 'net/ssh'
require 'parallel'

# core functions
class Dolphin::Base < Thor
  include Thor::Actions

# =============================================================================
# class options
# =============================================================================

  # deploy environment
  class_option :env, aliases: '-e', type: :string, default: 'alpha'
  # deploy to one specific target server
  class_option :target, aliases: '-t', type: :string, default: nil
  # deploy to one specific server group
  class_option :group, aliases: '-g', type: :string, default: nil
  # deploy to localhost
  class_option :local, aliases: '-l', type: :boolean, default: false
  # dry-run
  class_option :dry, aliases: '-d', type: :boolean, default: false

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
    # dry-run
    if options[:dry]
      puts "Capture on #{server}: #{command}"
      return '' # empty string for default unix return result
    end

    # capture output from one target server
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

  def execute(menu, target_server=nil)
    # execute commands defined in menu, when :target_server is passed in, only execute on this server
    commands = parse_commands(menu)
    puts "#{'*'*10}Executing commands#{'*'*10}\n"
    commands.each do |command|
      puts "#{command}\n"
    end
    puts "#{'='*60}\n"

    if target_server # solo
      tracks = 1
      target = [target_server]
    else
      # use Parallel to execute commands on multiple servers in parallel
      tracks = @servers.size
      # 3 threads maximum
      tracks = 3 if tracks > 3
      target = @servers
    end

    # dry-run
    if options[:dry]
      puts "Running on: #{target}"
      puts "#{'='*60}\n"
      return
    end

    # record output to display at the end
    output = {}

    Parallel.map(target, in_threads: tracks) do |server|
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
          ch.send_data "source ~/.bashrc\n"

          # pick up ruby
          ch.send_data "chruby >& /dev/null\n"

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

  def upload(source, dest, target_server=nil)
    if target_server # solo
      tracks = 1
      target = [target_server]
    else
      # use Parallel to execute commands on multiple servers in parallel
      tracks = @servers.size
      # 3 threads maximum
      tracks = 3 if tracks > 3
      target = @servers
    end

    Parallel.map(target, in_threads: tracks) do |server|
      command = "scp #{source} #{@user}@#{server}:#{dest}"
      puts command

      # dry-run
      unless options[:dry]
        raise unless system(command, out: $stdout, err: :out)
      end
    end
  end

end
