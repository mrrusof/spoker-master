# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :db do

  DB_CONTAINER_NAME='spoker-master_db'
  DB_IMAGE_NAME='postgres'
  DB_IMAGE_TAG='15.1-alpine3.17'
  DB_PASSWORD=Rails.configuration.database_configuration[Rails.env]['password']
  DB_USER=Rails.configuration.database_configuration[Rails.env]['user']
  DB_PORT=Rails.configuration.database_configuration[Rails.env]['port']
  DB_NAME=Rails.configuration.database_configuration[Rails.env]['database']

  desc 'Start local db.'
  task :start do
    sh <<~EOS
       docker run --detach \
                  --rm \
                  --env POSTGRES_PASSWORD=#{DB_PASSWORD} \
                  --env POSTGRES_USER=#{DB_USER} \
                  --publish #{DB_PORT}:5432 \
                  --name #{DB_CONTAINER_NAME} \
                  #{DB_IMAGE_NAME}:#{DB_IMAGE_TAG}
       EOS
  end

  desc 'Stop local db.'
  task :stop do
    sh <<~EOS
       docker stop #{DB_CONTAINER_NAME} || true
       EOS
  end

  desc 'Wait for local db to start.'
  task :wait do
    sh <<~EOS
       while ! PGPASSWORD=#{DB_PASSWORD} psql -p #{DB_PORT} -h 127.0.0.1 --user #{DB_USER} -c '\\d'; \
         do sleep 0.215; \
       done
       EOS
  end

  desc 'Connect to local db using psql.'
  task :psql do
    exec "PGPASSWORD=#{DB_PASSWORD} psql -p #{DB_PORT} -h 127.0.0.1 #{DB_NAME} #{DB_USER}"
  end
end

RAILS_MASTER_KEY=ENV['RAILS_MASTER_KEY']
COMMIT_ID=`which git >/dev/null 2>&1 && git show --pretty=format:%h --no-patch`
IMAGE_NAME='spoker-master'
IMAGE_TAG=COMMIT_ID

namespace :image do
  desc 'Build docker image.'
  task :build do
    sh build_image_cmd
  end
end

namespace :prod do

  PROD_HOST='spoker-master'
  UNIT_NAME='spoker-master'
  REPO_NAME='spoker-master'
  PROD_CONTAINER_NAME='spoker-master'
  GIT_REPO_URL="git@github.com:mrrusof/#{REPO_NAME}.git"

  namespace :db do
    desc 'Create production db.'
    task :create do
      abort_if_dir_dirty

      sh "#{non_interactive_ssh_cmd} -- '#{run_container_cmd('bundle exec rails db:create', :non_interactive).strip}'"
    end

    desc 'Migrate production db.'
    task :migrate do
      abort_if_dir_dirty

      sh "#{non_interactive_ssh_cmd} -- '#{run_container_cmd('bundle exec rails db:migrate', :non_interactive).strip}'"
    end

    desc 'Seed production db.'
    task :seed do
      abort_if_dir_dirty

      sh "#{non_interactive_ssh_cmd} -- '#{run_container_cmd('bundle exec rails db:seed', :non_interactive).strip}'"
    end
  end

  namespace :image do
    desc 'Build docker image in production host.'
    task :build do
      abort_if_dir_dirty

      sh "#{non_interactive_ssh_cmd} -- '#{remote_build_cmd.strip}'"
    end

    desc 'Prune all docker images for app except latest in production.'
    task :prune do
      abort_if_dir_dirty

      prune_cmd = <<EOS.strip
set -x;
latest=$(docker images | grep #{IMAGE_NAME}\\ \\\\+latest | awk \\{\\ print\\ \\$3\\ \\});
docker images | grep #{IMAGE_NAME} | grep -v $latest | awk \\{\\ print\\ \\$3\\ \\} | xargs -n 1 docker rmi
EOS

      sh "#{non_interactive_ssh_cmd} -- '#{prune_cmd}'"
    end
  end

  desc 'Deploy app in production.'
  task :deploy do
    abort_if_dir_dirty

    sh <<EOS
#{non_interactive_ssh_cmd} -- ' \
    #{remote_build_cmd.strip} && \
    #{restart_service_cmd} \
'
EOS
  end

  desc 'Restart app in production.'
  task :restart do
    sh "#{non_interactive_ssh_cmd} -- #{restart_service_cmd}"
  end

  desc 'Start app in production.'
  task :start do
    sh "#{non_interactive_ssh_cmd} -- #{start_service_cmd}"
  end

  desc 'Stop app in production.'
  task :stop do
    sh "#{non_interactive_ssh_cmd} -- #{stop_service_cmd}"
  end

  desc 'Start a production console.'
  task :console do
    sh "#{interactive_ssh_cmd} -- '#{run_container_cmd('bundle exec rails console', :interactive).strip}'"
  end

  desc 'Start a production shell.'
  task :shell do
    sh "#{interactive_ssh_cmd} -- '#{run_container_cmd('/bin/sh', :interactive).strip}'"
  end

  def interactive_ssh_cmd
    "ssh -A -t #{PROD_HOST}"
  end

  def non_interactive_ssh_cmd
    "ssh -A #{PROD_HOST}"
  end

  def restart_service_cmd
    "systemctl restart #{UNIT_NAME}"
  end

  def start_service_cmd
    "systemctl start #{UNIT_NAME}"
  end

  def stop_service_cmd
    "systemctl stop #{UNIT_NAME}"
  end

  def remote_build_cmd
  <<~EOS
    set -x; \
    cd /tmp; \
    git clone #{GIT_REPO_URL}; \
    cd /tmp/#{REPO_NAME}; \
    git fetch --all; \
    if ! git checkout #{COMMIT_ID}; then \
      echo Could not checkout commit #{COMMIT_ID}, check that you pushed it.; \
      exit; \
    fi; \
    #{build_image_cmd.strip}
  EOS
  end

  def run_container_cmd command, mode
  <<~EOS
    docker rm --force #{PROD_CONTAINER_NAME}.command; \
    docker run --env-file /etc/#{UNIT_NAME}/env \
               --volume /var/run/docker.sock:/var/run/docker.sock \
               --volume /var/run/postgresql/:/var/run/postgresql/ \
               --rm \
               #{'-ti' if mode == :interactive} \
               --name #{PROD_CONTAINER_NAME}.command \
               #{IMAGE_NAME}:#{IMAGE_TAG} \
               #{command}
  EOS
  end

  def abort_if_dir_dirty
    unless working_dir_clean?
      abort 'There are uncommited changes.'
    end
  end

  def working_dir_clean?
    `git status --porcelain`.empty?
  end

end

# SHARED FUNCTIONS

def build_image_cmd
  <<EOS
docker build \
  --build-arg RAILS_MASTER_KEY=#{RAILS_MASTER_KEY} \
  -t #{IMAGE_NAME}:#{IMAGE_TAG} \
  -t #{IMAGE_NAME}:latest \
  .
EOS
end
