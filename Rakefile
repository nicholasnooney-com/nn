# coding: utf-8
task :default => [:list_tasks]

require 'html-proofer'

# Load configuration variables, and provide defaults for unspecified variables
load '_rake_config.rb' if File.exist?('_rake_config.rb')

$SITE_DIR ||= "_site/"
$POST_DIR ||= "_posts/"
$POST_EXT ||= ".md"

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

  desc 'Preview the Site'
  task :preview => [:clean] do
    if File.exist?('env/localhost.key') && File.exist?('env/localhost.crt') then
      jekyll('serve --ssl-cert env/localhost.crt --ssl-key env/localhost.key')
    else
      jekyll('serve')
    end
  end
  task :serve => [:preview]

  desc 'Deploy the Site (clean, build, test)'
  task :deploy => [:clean, :build, :test] do
    puts "Build Complete!"
  end

  desc 'Clean the Site'
  task :clean do
    jekyll('clean')
  end
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
    while File.exists?($POST_DIR + filename)
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

  desc 'Push changes to the GitHub Repository'
  task :publish => ["ci:test"] do
    puts "Publishing Changes ..."
    time = Time.new

    %x{git add -A && git commit -m "Autopush by Rakefile at #{time}"}
    %x{git push origin master}
  end
end

# Tasks in the top-level namespace
desc 'Shorthand for ci:deploy'
task :deploy => ["ci:deploy"]

desc 'Shorthand for author:post'
task :post, [:date, :title, :post] do |t, args|
  Rake::Task["author:post"].invoke(args[:date], args[:title], args[:post])
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
