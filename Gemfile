source "https://rubygems.org"
ruby RUBY_VERSION

gem "rake", "~> 12.0"

# Jekyll Gems and Plugins
gem "jekyll"

# The theme can be developed by providing a local source. The rakefile has
# commands that allow the source of the theme gem to be updated automatically.
# Those commands work by finding the comment line "Theme Gem" and modifying the
# following line.

# Theme Gem
gem "jekyll-theme-nn"

# Site Plugins
group :jekyll_plugins do
    gem "jekyll-feed", ">= 0.6"
    gem "jekyll-assets", ">= 3.0"
    gem "mini_magick"
end

# Development Gems
group :development do
    gem "html-proofer"
    gem "fileutils"
    gem "thin"
    gem "rack"
end

# Platform Specific Gems

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
