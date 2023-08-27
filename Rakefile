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
