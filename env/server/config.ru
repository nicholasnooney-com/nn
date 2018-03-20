# coding: utf-8
require 'thin'

# Load configuration variables, and provide defaults for unspecified variables
load 'env/_rake_config.rb' if File.exist?('env/_rake_config.rb')

# Ensure $SITE_DIR is defined if not specified in env/_rake_config.rb
$SITE_DIR ||= "_site/"

# The Logfile is used to record HTTP interactions with the development server
# for debugging purposes.
$SERVER_LOG = "env/logs/server.log"
$SERVER_DIR = File.dirname($SERVER_LOG)

FileUtils.mkdir_p($SERVER_DIR) unless File.directory?($SERVER_DIR)
logger = Logger.new($SERVER_LOG)
use Rack::CommonLogger, logger

# Set up the server handler
server = Proc.new { |env|
    req = Rack::Request.new(env)
    index_file = File.join($SITE_DIR, req.path_info, "index.html")

    if File.exists?(index_file)
        # Rewrite to index
        req.path_info = File.join(req.path_info, "index.html")
    end

    Rack::Directory.new($SITE_DIR).call(env)
}

# Run the server
run server
