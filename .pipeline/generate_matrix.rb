require 'json'
require 'optparse'
require 'net/http'
require 'time'

# Gets latest ruby versions from endoflife.date
#
# @return [Array] The current supported ruby versions.
def supported_ruby_versions
  # Define the API URL
  url = 'https://endoflife.date/api/ruby.json'

  # Fetch the data from the API
  uri = URI(url)
  response = Net::HTTP.get(uri)

  # Parse the JSON response
  ruby_versions = JSON.parse(response)
  latest_versions = []
  # Extract and display the supported versions
  supported_versions = ruby_versions.select { |version| version['eol'] > Time.now.iso8601 }
  supported_versions.each do |version|
    puts "Ruby #{version['cycle']} - Latest Version: #{version['latest']}, EOL: #{version['eol']}"
    latest_versions << version['latest']
  end
  latest_versions
end


# Generates a matrix of ruby base images to build
#
# @param dockerfile_dir [String] the subdirectory where the dockerfile is located.
# @return [Hash] the github build matrix
def generate_ruby_matrix(dockerfile_dir)
  supported_ruby_versions.map do |version|
    {"dockerfile_dir" => dockerfile_dir, "build_args" => "RUBY_VERSION=#{version}"}
  end
end

# Generates a matrix of images build on a schedule
#
# @return [Hash] the github build matrix
def schedule_matrix
  {"include" => generate_ruby_matrix("ruby-image")}
end

# Generates a matrix from a workflow dispatch event
#
# @param dockerfile_dir [String] the subdirectory where the dockerfile is located.
# @return [Hash] the github build matrix
def workflow_dispatch_matrix(dockerfile_dir)
  case dockerfile_dir
  when 'ruby-image'
    {"include" => generate_ruby_matrix(dockerfile_dir)}
  else
    {"include" => [{"dockerfile_dir" => dockerfile_dir}]}
  end
end

# Generates the default build matrix
#
# @return [Hash] the github build matrix
def default_matrix
  {
    "include" => [
      {"dockerfile_dir" => "debug-image"},
      *generate_ruby_matrix("ruby-image")
    ]
  }
end

# Generates a matrix from a workflow dispatch event
#
# @param dockerfile_dir [String] the subdirectory where the dockerfile is located.
# @return [Hash] the github build matrix
def set_matrix(event_name, dockerfile_dir = nil)
  puts "Building matrix for event name #{event_name} and dockerfile in #{dockerfile_dir}"
  matrix = case event_name
           when 'schedule'
             puts 'Running schedule event'
             schedule_matrix
           when 'workflow_dispatch'
             puts 'Running workflow_dispatch event'
             raise 'Pease specify a dockerfile_dir' if dockerfile_dir.nil? || dockerfile_dir.empty?
             workflow_dispatch_matrix(dockerfile_dir)
           else
             puts 'Running default_matrix event'
             default_matrix
           end

  puts "matrix=#{matrix.to_json}"
  matrix
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: script.rb [options]"

  opts.on("-e", "--event_name EVENT_NAME", "Event name") do |e|
    options[:event_name] = e
  end

  opts.on("-d", "--dockerfile_dir DOCKERFILE_DIR", "Dockerfile directory") do |d|
    options[:dockerfile_dir] = d
  end
end.parse!

event_name = options[:event_name] || ENV['GITHUB_EVENT_NAME']
dockerfile_dir = options[:dockerfile_dir] || ENV['GITHUB_EVENT_INPUTS_DOCKERFILE_DIR']
matrix = set_matrix(event_name, dockerfile_dir)

puts "::group::Job matrix"
puts JSON.pretty_generate(matrix)
puts "::endgroup::"

# Set GitHub Action output
File.open(ENV['GITHUB_OUTPUT'], 'a') do |file|
  file.puts("matrix=#{matrix.to_json}")
end
