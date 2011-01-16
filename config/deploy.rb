 set :application, "foolol"
  set :user, "foolol"
  set :password, "haribo"
  set :use_sudo, false
 # set :rake, "/usr/bin/rake1.9.1"
  set :repository, "file://."
  set :deploy_via, :copy
  set :deploy_to, "/var/www/#{application}"
  set :scm, :git
  set :git_enable_submodules, 1         # Make sure git submodules are populated

  set :port, 22                    # The port you've setup in the SSH setup section
  set :location, "87.98.155.135"
  set :app_server, :passenger
  set :domain, "www.foolol.fr"

  role :app, location
  role :web, location
  role :db,  location, :primary => true
  after "deploy", "deploy:cleanup"