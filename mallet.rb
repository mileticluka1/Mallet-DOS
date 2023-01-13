require 'net/http'
require 'thread'
require 'optparse'

# Initialize a variable to keep track of failed requests
$failed_requests = 0

def stress_test(url)
  # Sends a GET request to the specified URL
  begin
    response = Net::HTTP.get_response(URI(url))
    if response.code != "200"
      $failed_requests += 1
    end
  rescue => e
    $failed_requests += 1
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: script.rb [OPTIONS]"
    opt.on("-u","--url URL","URL of website to stress test") do |url|
      options[:url] = url
    end
    opt.on("-t","--threads NUM","Number of threads to use") do |t|
      options[:threads] = t.to_i
    end
    opt.on("-h","--help","help") do
      puts opt_parser
      exit
    end
  end
  opt_parser.parse!
  if options[:url] == nil
    puts "Please provide url using -u or --url option"
    exit
  elsif options[:threads] == nil
    puts "Please provide number of threads using -t or --threads option"
    exit
  end
  threads = []
  # Start specified number of threads that will send GET requests to the specified URL
  options[:threads].times do
    threads << Thread.new { stress_test(options[:url]) }
  end
  threads.each(&:join)
  puts "Total failed requests: #{$failed_requests}"
end
