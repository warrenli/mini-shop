# =====================================
# Github settings
# =====================================
default_run_options[:pty] = true
set :repository, "git://github.com/yourgit/something.git" # GitHub clone URL
set :scm, "git"
set :branch, "master"
set :scm_verbose, true

set :ssh_options, { :forward_agent => true }

set :user, "deployer"
set :scm_passphrase, "pa$$w0rd" #This is the passphrase for the ssh key on the server deployed to



# =====================================
# Dreamhost settings
# =====================================
set :user, 'username'                   # Dreamhost username
set :domain, 'server.dreamhost.com'     # Dreamhost servername where your account is located
set :project, 'appname'                 # Your application as its called in the repository
set :application, 'appname.domain.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/#{application}" # The standard Dreamhost setup

set :deploy_to, applicationdir
set :deploy_via, :remote_cache

role :app, domain
role :web, domain
role :db, domain, :primary => true



# =====================================
# Additional settings
# =====================================
set :use_sudo, false
set :git_enable_submodules, 1

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end


# for use with shared files (e.g. config files)
after "deploy:update_code" do
  run "ln -s #{deploy_to}/database.yml #{release_path}/config"
end

