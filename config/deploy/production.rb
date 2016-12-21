require 'net/ssh/proxy/command'

set :repo_url, 'git@github.com:aytossreyes/consul.git'
set :deploy_to, deploysecret(:deploy_to)
set :server_name, deploysecret(:server_name)
set :db_server, deploysecret(:db_server)
set :branch, :master
set :ssh_options, port: deploysecret(:ssh_port)
set :stage, :production
set :rails_env, :production

server deploysecret(:server), user: deploysecret(:user), roles: %w(web app db importer cron)

set :ssh_options, {
  proxy: Net::SSH::Proxy::Command.new("ssh -p 22 ubuntu@populate01 -W %h:%p"),
  forward_agent: true,
  user: 'ubuntu'
}

set :pty, false
