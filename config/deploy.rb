# config valid only for Capistrano 3.1
lock '3.1.0'

set :rvm_ruby_version, 'ruby-2.1.0@cuntbot'

set :application, 'cuntbot'
set :repo_url, 'git@github.com:andrewduhan/cuntbot.git'
set :branch, "master"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '~/cuntbot'

# require "rvm/capistrano"
# set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
# set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs
# set :bundle_dir, ''
# set :bundle_flags, '--system --quiet'

# set :default_env, { rvm_bin_path: '~/.rvm/bin' }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :rvm do
#   task :trust_rvmrc do
#     run "rvm rvmrc trust #{release_path}"
#   end
# end

namespace :deploy do

  task :symlink_config do
    on roles(:all) do
      # execute "cd #{release_path} && bundle install"
      execute  "rm -rf #{release_path}/data   && ln -nfs #{shared_path}/data #{release_path}/data"
      execute  "rm -rf #{release_path}/config && ln -nfs #{shared_path}/config #{release_path}/config"
      execute  "rm -f #{current_path}         && ln -s #{release_path} #{current_path}"
    end
  end

  # task :kill_running_bot do
  #   on roles(:all) do
  #     begin
  #       execute  "cat #{shared_path}/pid | xargs kill -9"
  #     rescue
  #     end
  #   end
  # end

  # task :start_new_bot do
  #   on roles(:all) do
  #     execute  "cd #{current_path}; ruby cuntbot.rb &"
  #     execute  "#{shared_path}/pid < $!"
  #   end
  # end

  # task :after_publishing do
  #   invoke 'deploy:symlink_config'
  #   invoke 'deploy:kill_running_bot'
  #   invoke 'deploy:start_new_bot'
  # end

  after :publishing, :symlink_config

end

# after :deploy, "rvm:trust_rvmrc"
