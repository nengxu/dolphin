# settings require user input
# -----------------------------
# name of this application
application = 'best_app'

# settings with default values
# -----------------------------
deploy_dir = File.expand_path('../..', __FILE__)
sockets = "#{deploy_dir}/tmp/sockets"
pids = "#{deploy_dir}/tmp/pids"

environment ENV['RAILS_ENV']

# number of cpu
nproc = `nproc`.to_i

if nproc > 1
  # multiple cpu, running in cluster mode
  threads 2,16
  workers nproc
  preload_app!
else
  # in single mode
  threads 8,32
end

daemonize true
state_path "#{pids}/#{application}.state"

# pumactl socket
activate_control_app "unix://#{sockets}/pumactl.sock"

# using unix socket
bind "unix://#{sockets}/#{application}.sock"
