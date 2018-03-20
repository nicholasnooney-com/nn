source "https://rubygems.org"
ruby RUBY_VERSION

gem "rake", "~> 12.0"

# Jekyll Gems and Plugins
gem "jekyll"
gem "jekyll-theme-nn"
#gem "jekyll-theme-nn", :path => "C:/Users/Nick/Documents/GitHub/jekyll-theme-nn"
#gem "jekyll-theme-nn", :path => "/Users/nooney/Sites/jekyll-theme-nn"

group :jekyll_plugins do
    gem "jekyll-feed", ">= 0.6"
end

# Development Gems
group :development do
    gem "html-proofer"
    gem "thin"
    gem "rack"
end

# Platform Specific Gems

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
