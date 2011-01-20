require File.join(File.dirname(__FILE__), 'app')

use Rack::ShowExceptions
use Rack::Static, :urls => [ '/favicon.ico', '/css', '/images', '/cdn', '/js' ], :root => "public"

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("../../logs/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

set :run, false
set :environment, :production
run Sinatra::Application