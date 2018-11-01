---
layout: post
title: "Managing this Site with Rake"
date: 2018-03-07 22:40:25 -0500
category: web
tags: this-site
---

In order to remember how to correctly build this site, I decided to use `Rake`.
Rake is Ruby's version of Make: by specifying targets to build and how to build
them, I can easily perform a complex series of commands to manage this site.
Because Rake is so versatile in declaring targets, I use it to create new posts,
run continuous integration, and even generate SSL Certificates for my local
development environment.

<!-- excerpt separator -->

### Beginning with Rake

After installing Rake, all I had to do was create a `Rakefile` in the root of
my site. I've never programmed in Ruby before, but it was pretty easy to get
started. All that is needed is the name of a task and a useful description,
and then we can run a command. Prior to using the rakefile, I had to run a long
command every time I wanted to build my site.

```
bundle exec jekyll build
```

That's hard to remember! I would much rather run `build` in order to build my
site. So I can make a target to build my site and insert it in the `Rakefile`.

```ruby
desc 'Build the Site'
task :build do
  sh 'bundle exec jekyll build'
end
```

In this code, `desc` sets the description of the task, `task` describes the
task named `build`, and `sh` executes code in a shell script. This is neat! Now,
instead of having to remember the entire command, I can just run `rake build`.

In order to clean the site and rebuild it, I have to run `jekyll clean` followed
by `rake build`. It would be nice to have one tool run everything for me, so
that I don't get accidentally confused. Let's make a target to clean the site
too.

```ruby
desc 'Clean the Site'
task :clean do
  sh 'jekyll clean'
end
```

This is great! Now I run `rake clean; rake build` in order to rebuild my entire
site. That's a lot of typing though. I could make it even shorter by running
`rake rebuild`. Let's make that target.

```ruby
desc 'Rebuild the Site'
task :rebuild => [:clean, :build]
```

Unlike the other tasks, this one declares a dependency. The `rebuild` task must
complete the `clean` task, then complete the `build` task, in that order. Also
notice that it doesn't have a body to execute. We don't need one because
rebuilding the site is already fully described by the `clean` and `build` tasks.

I am a forgetful person sometimes, and with all of these tasks, it is hard for
me to remember what I can run. Thankfully, Rake has the option `-T` to list all
tasks that it finds in the Rakefile. But sometimes I even forget that. So in
order to make my life easier, I made a task to list all of the tasks.

```ruby
task :list_tasks do
  sh 'rake -T'
end
```

This task doesn't have a description. Rake doesn't show tasks in the output of
`rake -T` if they don't have a description. That's good, so I won't see this
reminder task for me. But how do I remember to run `rake list_tasks`? Sometimes
I may even forget that. The solution is to set a default task. The default task
is a task that is run by Rake when no other task is specified. It uses the
special `:default` task name.

```ruby
task :default => [:list_tasks]
```

Voila! Now I can run `rake` whenever I forget what I can do, and Rake will tell
me!

### Taking Rake to the Next Level

Now that I've gotten setup with Rake, I can expand upon it to perform more
complicated tasks. Jekyll recommends using HTMLProofer to verify that all the
links in your site work. We can make a command called `test` that tests all the
links in the site.

To do this, we need to include `html-proofer` and use it directly from Rake.
Since HTMLProofer is ruby code and Rake executes Ruby code, this makes perfect
sense to do.

```ruby
require 'html-proofer'

desc 'Test the Site'
task :test do
  options = {
    :check_sri => true,
    :check_html => true,
    :check_img_http => true,
    :enforce_https => true
  }
  begin
    HTMLProofer.check_directory('_site/', options).run
  rescue => msg
    puts "#{msg}"
  end
end
```

I had no idea how to setup and run HTMLProofer, but I got sensible options from
the website. I don't like that I had to hardcode `_site/` though. What if I ever
change the directory to build to? Jekyll supports the `-d` option to specify
where to run the site from; all that I really care about is that the output from
the `:build` task matches the directory that gets tested. Let's make a variable.

```ruby
$SITE_DIR = "_site/"

desc 'Build the Site'
task :build do
  sh 'bundle exec jekyll build -d' + $SITE_DIR
end

desc 'Test the Site'
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
```

Now we're getting somewhere. All I have to do is edit the `$SITE_DIR` variable
and then my site gets build and tested in that location!

There's a lot more that can be done with Rake, and I'm just scrating the surface
with the Rakefile for this project. You can see the current Rakefile
[here][master-rakefile]. If I do anything more advanced, I'll write another
post about it.

[master-rakefile]: https://github.com/nnooney/nn/blob/master/Rakefile
