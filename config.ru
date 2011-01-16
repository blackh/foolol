require File.join(File.dirname(__FILE__), 'app')

use Rack::ShowExceptions
use Rack::Static, :urls => [ '/favicon.ico', '/css', '/images', '/cdn', '/js' ], :root => "public"

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

run Application
