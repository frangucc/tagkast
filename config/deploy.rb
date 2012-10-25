#require "delayed/recipes"
require './config/boot'
require "bundler/capistrano"
require 'capistrano/ext/multistage'
require "rvm/capistrano"

set :stages, %w(staging production)
set :default_stage, "staging"
ssh_options[:paranoid] = false 

# require 'whenever/capistrano'
# Load RVM's capistrano plugin.
# set :normalize_asset_timestamps, false
load "deploy/assets"

set :rvm_ruby_string, 'ruby-1.9.3-p286'
set :rvm_type, :user

set :application,     "tagkast"
set :keep_releases,   10

set :scm,           :git
set :repository,    "git@github.com:frangucc/tagkast.git"
set :branch,        "master"
set :deploy_via,    :remote_cache
set :git_shallow_clone, 1


role :web, "50.57.94.68"                          # Your HTTP server, Apache/Nginx/etc
role :app, "50.57.94.68"                          # This may be the same as your `Web` server
role :db,  "50.57.94.68", :primary => true        # This is where Rails migrations will run

set :user,          "fpinto"
set :use_sudo,      true
ssh_options[:forward_agent] = true

task :production do
  set :rails_env,   "production"
  set :application, 'tagkast_production'
  set :deploy_to,   "/var/www/tagkast/pruduction"
end


task :staging do
  set :rails_env,   "staging"
  set :application, 'tagkast_staging'
  set :deploy_to,   "/var/www/tagkast/staging"
end


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :seed, :roles => :db do
    run("cd #{deploy_to}/current && /usr/local/bin/rake db:seed RAILS_ENV=#{rails_env}")  
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && /usr/local/bin/rake RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end  

end


desc "Run a task on a remote server. cap staging rake:invoke task=blah"  
# run like: cap staging invoke_rake task=a_certain_task  
task :invoke_rake do
  run("cd #{deploy_to}/current && /usr/local/bin/rake #{ENV['task']} RAILS_ENV=#{rails_env}")  
end  


task :symlink_database_and_system_folder do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end
before  "deploy:assets:precompile",     "symlink_database_and_system_folder"

# after   "deploy:setup", "symlink_database_and_system_folder"

## Should comment in For delayed_job
##after "deploy:stop",    "delayed_job:stop"
#after "deploy:start",   "rake:recompile_assest"
#after "deploy:restart", "rake:recompile_assest"