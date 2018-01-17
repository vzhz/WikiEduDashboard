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

run 'gem install bundler' if `which bundler`.empty?
run 'bundle install'
run 'sudo apt update'
run 'sudo apt install pandoc'

puts 'ohai'
