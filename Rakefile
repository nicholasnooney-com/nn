# coding: utf-8
task :default => [:list_tasks]

require 'html-proofer'
require 'tempfile'
require 'fileutils'

# Load configuration variables, and provide defaults for unspecified variables
load 'env/_rake_config.rb' if File.exist?('env/_rake_config.rb')

$SITE_DIR  ||= "_site/"
$POST_DIR  ||= "_posts/"
$DRAFT_DIR ||= "_drafts/"
$POST_EXT  ||= ".md"

$SSL_CONF ||= "env/ssl/localhost.conf"
$SSL_CERT ||= nil
$SSL_KEY  ||= nil

$SERVER_ADDR ||= "localhost"
$SERVER_PORT ||= "4000"

# Tasks related to building and testing the site. These tasks run both locally
# and on the server as part of the continuous integration pipeline.
namespace "ci" do
  desc 'Build the Site (Incremental)'
  task :build, [:env, :verbose] do |t, args|
    # Development is the default environment. This is to match the same behavior
    # as Jekyll. Other tasks depend on "dev" as the default environment.
    args.with_defaults(:env => 'dev', :verbose => false)
    configFiles = [
        "_config.yml"
    ]
    if File.exist?("env/_config_#{args.env}.yml") then
        configFiles.push("env/_config_#{args.env}.yml")
    end

    cmd = 'build -d ' + $SITE_DIR + ' --config ' + configFiles.join(",")
    if args.verbose
      cmd += ' -V'
    end

    jekyll(cmd)
  end

  desc 'Build the Site (From Scratch)'
  task :rebuild, [:env] do |t, args|
    args.with_defaults(:env => 'dev')
    Rake::Task["ci:clean"].invoke()
    Rake::Task["ci:build"].invoke(args.env, false)
  end

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
  task :deploy, [:env] do |t, args|
    args.with_defaults(:env => 'prod')
    Rake::Task["ci:clean"].invoke()
    Rake::Task["ci:build"].invoke(args.env, true)
    Rake::Task["ci:test"].invoke()
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
      puts "in env/_rake_config.rb"
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

  # The :preview task intentionally rebuilds the site with the default "dev"
  # environment.
  desc 'Preview the Site'
  task :preview do
    Rake::Task["ci:rebuild"].invoke("dev", false)
    opts = [
        "-R env/server/config.ru",
        "-a #{$SERVER_ADDR}",
        "-p #{$SERVER_PORT}"
    ]
    if File.exist?($SSL_CERT) && File.exist?($SSL_KEY) then
      opts.push("--ssl")
      opts.push("--ssl-cert-file #{$SSL_CERT}")
      opts.push("--ssl-key-file #{$SSL_KEY}")
    end

    bundle_exec("thin start " + opts.join(" "))
  end
  task :serve => [:preview]

  # The :build task in this section performs a one-off verbose build with the
  # "dev" environment.
  desc 'Build the site with debug'
  task :build do
    Rake::Task["ci:build"].invoke("dev", true)
  end
end

# Tasks related to authoring content for the site
namespace "author" do
  desc 'Create a new post'
  task :post, [:title, :draft, :date] do |t, args|
    # Validate arguments to the create-post task
    if args.title == nil then
      puts "Error: No Title Specified"
      puts "Usage: post[title,draft,date]"
      puts "  TITLE is a string"
      puts "  DRAFT is a boolean (default false)"
      puts "  DATE is of the form YYYY-MM-DD; leave blank or nil for"
      puts "    today's date"
      exit 1
    end

    if (args.date != nil and args.date != "nil" and args.date != "" and
      args.date.match(/[0-9]+-[0-9]+-[0-9]+/) == nil) then
      puts "Error: Invalid Date"
      puts "Usage: post[title,draft,date]"
      puts "  TITLE is a string"
      puts "  DRAFT is a boolean (default false)"
      puts "  DATE is of the form YYYY-MM-DD; leave blank or nil for"
      puts "    today's date"

      puts "Example:"
      puts "  post[\"#{args.title}\"]"
      puts "  post[\"#{args.title}\",true]"
      puts "  post[\"#{args.title}\",false,#{Time.new.strftime("%Y-%m-%d")}]"
      exit 1
    end

    # Calculate Front Matter variables
    post_title = args.title
    post_date = (args.date != "" and args.date != "nil" and args.date != nil) ?
      args.date : Time.new.strftime("%Y-%m-%d %H:%M:%S %z")
    post_dir = $POST_DIR

    if args.draft == "true" or args.draft == "True" then
      post_dir = $DRAFT_DIR
    end

    # A Helper function for generating a filename
    def slugify(title)
      return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    # Generate the unique filename for the new post
    filename = post_date[0..9] + "-" + slugify(post_title) + $POST_EXT
    i = 1
    while File.exist?(post_dir + filename)
      filename = post_date[0..9] + "-" +
        File.basename(slugify(post_title)) + "-" + i.to_s + $POST_EXT
      i += 1
    end

    # Create the new post
    File.open(post_dir + filename, 'w') do |f|
      f.puts "---"
      f.puts "layout: post"
      f.puts "title: \"#{post_title}\""
      f.puts "date: #{post_date}"
      f.puts "category:"
      f.puts "tags:"
      f.puts "---"
      f.puts ""
      f.puts "<!-- excerpt separator -->"
    end

    puts "Post created: \"#{post_dir}#{filename}\""
  end

  desc 'Publish all changes (git push origin HEAD)'
  task :publish => ["ci:test"] do
    puts "Publishing Changes ..."
    time = Time.new

    %x{git add -A && git commit -m "Autopush by Rakefile at #{time}"}
    %x{git push origin HEAD}
  end
end

# Tasks related to working with the theme
namespace "theme" do
  desc 'Set the theme source (gem, dev)'
  task :source, [:src, :path] do |t, args|
    # Validate arguments
    if args.src == nil then
      puts "Error: No source provided"
      puts "Provide a source for the theme gem. Use one of the following:"
      puts "  - gem: Use the gem available on rubygems"
      puts "  - dev: Use the gem at the path provided"
      exit 1
    end

    if (args.src != "gem" and args.src != "dev") then
      puts "Error: Invalid source provided"
      puts "Provide a source for the theme gem. Use one of the following:"
      puts "  - gem: Use the gem available on rubygems"
      puts "  - dev: Use the gem at the path provided"
      exit 1
    end

    if (args.src == "dev" and args.path == nil) then
      puts "Error: No path provided, required by dev source"
      puts "Provide a path to the theme if using the dev source"
      exit 1
    end

    gemfile = "Gemfile"
    if File.exist?(gemfile) then
      # Update the theme gem source by using a temporary file
      tmpfile = Tempfile.new('Gemfile.tmp')
      begin
        themegem = ""
        foundflag = false
        File.open(gemfile) do |f|
          f.each_line do |line|

            # If we have found the line to modify, parse it here
            if (foundflag) then
              newline = line.split(",")[0].strip
              themegem = newline.split[1]
              if (args.src == "dev") then
                newline << ", :path => \"" + args.path + "\""
              end
              tmpfile.puts newline
              foundflag = false

            # Or if the line is the special line "# Theme Gem", then the next
            # line is our theme gem
            elsif (line.eql?("# Theme Gem\n")) then
              foundflag = true
              tmpfile.puts line

            # Otherwise copy the line as-is to the output file
            else
              tmpfile.puts line
            end
          end
        end

        # Copy the temporary file to the Gemfile
        tmpfile.close
        FileUtils.mv(tmpfile.path, gemfile)
      ensure
        tmpfile.close
        tmpfile.unlink
      end

      # Run bundle update to update the Gemfile.lock with the new source
      sh 'bundle update --local --conservative ' + themegem
    else
      puts "Error: Cannot locate Gemfile"
      exit 1
    end
  end
end

# Tasks in the main namespace
namespace "m" do
  desc 'Shorthand for ci:deploy'
  task :deploy, [:env] do |t, args|
    Rake::Task["ci:deploy"].invoke(args.env)
  end

  desc 'Shorthand for author:post'
  task :post, [:title, :draft, :date] do |t, args|
    Rake::Task["author:post"].invoke(args[:title], args[:draft], args[:date])
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
