# coding: utf-8
task :default => [:list_tasks]

require 'html-proofer'

# Load configuration variables, and provide defaults for unspecified variables
load '_rake_config.rb' if File.exist?('_rake_config.rb')

$SITE_DIR ||= "_site/"
$POST_DIR ||= "_posts/"
$POST_EXT ||= ".md"

$SSL_CONF ||= "env/ssl/localhost.conf"
$SSL_CERT ||= nil
$SSL_KEY  ||= nil

# Tasks related to building and testing the site. These tasks run both locally
# and on the server as part of the continuous integration pipeline.
namespace "ci" do
  desc 'Build the Site (Incremental)'
  task :build do
    jekyll('build -d ' + $SITE_DIR)
  end

  desc 'Build the Site (From Scratch)'
  task :rebuild => [:clean, :build]

  desc 'Test the currently built Site'
  task :test do
    options = {
      :check_sri => true,
      :check_html => true,
      :check_img_http => true,
      :enforce_https => true
    }
    begin
      HTMLProofer.check_directory($SITE_DIR, options).run
    rescue => msg
      puts "#{msg}"
    end
  end

  desc 'Deploy the Site (clean, build, test)'
  task :deploy => [:clean, :build, :test] do
    puts "Build Complete!"
  end

  desc 'Clean the Site'
  task :clean do
    jekyll('clean')
  end
end

# Tasks related to setting up the development environment
namespace "dev" do
  desc 'Generate self-signed SSL Cert via OpenSSL'
  task :ssl do
    # Ensure all necessary variables are defined
    if defined?($SSL_CONF).nil? || defined?($SSL_CERT).nil? || defined?($SSL_KEY).nil?
      puts "Error: Missing Variables"
      puts "Please ensure $SSL_CONF, $SSL_CERT, and $SSL_KEY are defined"
      exit 1
    end

    # Ensure no key already exists
    if File.exist?($SSL_CERT) || File.exist?($SSL_KEY) then
      puts "Error: Certificate Already Exists"
      puts "If you want to run this command, remove '" + $SSL_CERT + "' and"
      puts "'" + $SSL_KEY + "' and run this command again"
      exit 1
    end
    Dir.mkdir('env') unless File.exist?('env')

    # I use the following options with this command
    # Country Name: US
    # State or Province Name: .
    # Locality Name: .
    # Organization Name: .
    # Organizational Unit Name: .
    # Common Name: localhost
    # Email Address: .
    %x{openssl req -config #{$SSL_CONF} -new -x509 -sha256 -newkey rsa:2048 -nodes \
       -out #{$SSL_CERT} -keyout #{$SSL_KEY} -days 365}
  end

  desc 'Preview the Site'
  task :preview => ["ci:clean"] do
    if File.exist?($SSL_CERT) && File.exist?($SSL_KEY) then
      jekyll('serve --ssl-cert ' + $SSL_CERT + ' --ssl-key ' + $SSL_KEY)
    else
      jekyll('serve')
    end
  end
  task :serve => [:preview]
end

# Tasks related to authoring content for the site
namespace "author" do
  desc 'Create a new post'
  task :post, [:date, :title, :category] do |t, args|
    # Validate arguments to the create-post task
    if args.title == nil then
      puts "Error: No Title Specified"
      puts "Usage: post[date,title,category]"
      puts "  DATE is of the form YYYY-MM-DD; leave blank or nil for"
      puts "    today's date"
      puts "  TITLE is a string"
      puts "  CATEGORY is a string; leave blank or nil for no category"
      exit 1
    end

    if (args.date != nil and args.date != "nil" and args.date != "" and
      args.date.match(/[0-9]+-[0-9]+-[0-9]+/) == nil) then
      puts "Error: Invalid Date"
      puts "Usage: post[date,title,category]"
      puts "  DATE is of the form YYYY-MM-DD; leave blank or nil for"
      puts "    today's date"
      puts "  TITLE is a string"
      puts "  CATEGORY is a string; leave blank or nil for no category"

      puts "Example:"
      puts "  post[\"\",\"#{args.title}\"]"
      puts "  post[nil,\"#{args.title}\"]"
      puts "  post[,\"#{args.title}\"]"
      puts "  post[#{Time.new.strftime("%Y-%m-%d")},\"#{args.title}\"]"
      exit 1
    end

    # Calculate Front Matter variables
    post_title = args.title
    post_date = (args.date != "" and args.date != "nil" and args.date != nil) ?
      args.date : Time.new.strftime("%Y-%m-%d %H:%M:%S %z")
    post_category = args.category

    # A Helper function for generating a filename
    def slugify(title)
      return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    # Generate the unique filename for the new post
    filename = post_date[0..9] + "-" + slugify(post_title) + $POST_EXT
    i = 1
    while File.exist?($POST_DIR + filename)
      filename = post_date[0..9] + "-" +
        File.basename(slugify(post_title)) + "-" + i.to_s + $POST_EXT
      i += 1
    end

    # Create the new post
    File.open($POST_DIR + filename, 'w') do |f|
      f.puts "---"
      f.puts "layout: post"
      f.puts "title: \"#{post_title}\""
      f.puts "date: #{post_date}"
      f.puts "category: #{post_category}"
      f.puts "tags:"
      f.puts "---"
    end

    puts "Post created: \"#{$POST_DIR}#{filename}\""
  end

  desc 'Publish all changes (git push origin HEAD)'
  task :publish => ["ci:test"] do
    puts "Publishing Changes ..."
    time = Time.new

    %x{git add -A && git commit -m "Autopush by Rakefile at #{time}"}
    %x{git push origin HEAD}
  end
end

# Tasks in the main namespace
namespace "m" do
  desc 'Shorthand for ci:deploy'
  task :deploy => ["ci:deploy"]

  desc 'Shorthand for author:post'
  task :post, [:date, :title, :post] do |t, args|
    Rake::Task["author:post"].invoke(args[:date], args[:title], args[:post])
  end
end

task :list_tasks do
  sh 'rake -T'
end

# Support Functions
def jekyll(params = '')
  bundle_exec('jekyll ' + params)
end

def bundle_exec(command = '')
  sh 'bundle exec ' + command
end
