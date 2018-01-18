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
def run shell_command
  IO.popen(shell_command) do |output|
    while line = output.gets do
      print line
    end
  end
end

# Install dependencies

run 'sudo apt update'
run 'sudo apt install -y default-libmysqlclient-dev pandoc curl r-base nodejs mariadb-server'

run 'gem install bundler' if `which bundler`.empty?
run 'bundle install'

if `nodejs -v`[0].to_i < 6
  run 'curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -'
  run 'sudo apt install -y nodejs'
end

if `which yarn`.empty?
  run 'curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -'
  run 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list'
  run 'sudo apt update && sudo apt install -y yarn'
end

run 'yarn'
run 'sudo yarn global add phantomjs-prebuilt'
run 'sudo yarn global add bower'
run 'sudo yarn global add gulp'
run 'bower install'

# Rails and database config
run 'cp config/application.example.yml config/application.yml' unless File.exist? 'config/application.yml'
run 'cp config/database.example.yml config/database.yml' unless File.exist? 'config/database.yml'

run 'sudo mysql -e "CREATE USER \'dashboard\' IDENTIFIED BY \'password\';"'
run 'sudo mysql -e "CREATE DATABASE dashboard DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"'
run 'sudo mysql -e "CREATE DATABASE dashboard_testing DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"'
run 'sudo mysql -e "GRANT ALL ON dashboard.* TO \'dashboard\'"'
run 'sudo mysql -e "GRANT ALL ON dashboard_testing.* TO \'dashboard\'"'

# Build assets
run 'gulp build'

puts 'ohai'
