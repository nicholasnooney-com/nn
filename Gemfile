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
    gem "jekyll-feed", ">= 0.12"
    gem "jekyll-assets", ">= 3.0"
    gem "sprockets", "~> 3.7"
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
