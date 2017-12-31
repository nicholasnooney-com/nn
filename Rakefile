# coding: utf-8
task :default => [:list_tasks]

require 'html-proofer'

# Tasks
desc 'Build the site'
task :build do
    jekyll('build')
end

desc 'Test the site'
task :test do
    bundle_exec('htmlproofer ./_site')
end

desc 'Deploy the Site'
task :deploy => [:build, :test] do
    puts "Build Complete!"
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
