# Check for require ruby
REQUIRED_RUBY_VERSION = '2.5.0'

actual_ruby = `ruby -v`

unless actual_ruby.include? "ruby #{REQUIRED_RUBY_VERSION}"
  puts 'The wrong version of Ruby is being used.'
  puts "Required Ruby version: #{REQUIRED_RUBY_VERSION}"
  puts "Actual Ruby version: #{actual_ruby}"
  puts 'Please install and use the required Ruby version and try again.'
  exit
end

# Utility for printing shell output continuously.
def run shell_command, exit_on_failure: false, silent: false
  exit_status = nil

  IO.popen(shell_command) do |output|
    while line = output.gets do
      print line unless silent
    end
    output.close
    exit_status = $?.to_i
  end

  return if exit_status.zero?
  puts "Error with command: #{shell_command}"
  return exit_status unless exit_on_failure
  exit exit_status
end


# Install dependencies
if `which apt`.empty?
  puts 'Sorry, only Linux distros with `apt` are supported by this script.'
  exit 1
end

puts 'Installing required debian packages via `apt`...'
run 'sudo apt-get update', silent: true, exit_on_failure: true
run 'sudo apt-get install -y default-libmysqlclient-dev pandoc curl r-base nodejs mariadb-server', silent: true

if `which node`.empty? || `node -v`[1].to_i < 6
  puts 'Installing latest nodejs from nodesource.com...'
  run 'curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -'
  run 'sudo apt-get install -y nodejs'
end

if `which yarn`.empty?
  puts 'Installing yarn from yarnpgk.com...'
  run 'curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -'
  run 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list'
  run 'sudo apt-get update && sudo apt-get install -y yarn'
end

puts 'Install npm modules via `yarn`...'
run 'yarn', exit_on_failure: true, silent: true
run 'yarn global add phantomjs-prebuilt' if `which phantomjs`.empty?
run 'yarn global add bower' if `which bower`.empty?
run 'yarn global add gulp' if `which gulp`.empty?
run 'bower install', exit_on_failure: true

# Rails and database config
run 'cp config/application.example.yml config/application.yml' unless File.exist? 'config/application.yml'
run 'cp config/database.example.yml config/database.yml' unless File.exist? 'config/database.yml'

run 'sudo mysql -e "CREATE USER \'dashboard\' IDENTIFIED BY \'password\';"'
run 'sudo mysql -e "CREATE DATABASE dashboard DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"'
run 'sudo mysql -e "CREATE DATABASE dashboard_testing DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"'
run 'sudo mysql -e "GRANT ALL ON dashboard.* TO \'dashboard\'"'
run 'sudo mysql -e "GRANT ALL ON dashboard_testing.* TO \'dashboard\'"'

# Ruby gems
unless `bundle check` == "The Gemfile's dependencies are satisfied"
  puts 'Installing Ruby gems via `bundler`...'
  run 'gem install bundler' if `which bundler`.empty?
  run 'bundle install', exit_on_failure: true, silent: true
  puts 'Ruby gem dependencies installed. Please rerun this script to continue.'
  exit
end

`bundle exec rake db:migrate`
`bundle exec rake db:migrate RAILS_ENV=test`

# Build assets
run 'gulp build', exit_on_failure: true

puts 'ohai'
