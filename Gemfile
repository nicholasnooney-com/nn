source "https://rubygems.org"
ruby RUBY_VERSION

gem "rake", "~> 12.0"

# Jekyll Gems and Plugins
gem "jekyll"
gem "minima", "~> 2.0"

group :jekyll_plugins do
    gem "jekyll-feed", "~> 0.6"
end

# Development Gems
group :development do
    gem "html-proofer"
end

# Platform Specific Gems

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
