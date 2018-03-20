# A Plugin that will generate a series archive for each page that specifies the
# series: key in the post's frontmatter.
require "jekyll"

module Jekyll
  module Series
    class SeriesPage < Jekyll::Page
      attr_accessor :posts, :slug

      # Attributes for Liquid templates
      ATTRIBUTES_FOR_LIQUID = %w(
        posts
        title
        name
        path
        url
        permalink
      ).freeze

      # Initialize a new Series Page
      #
      # site - The Site object.
      # title - The name of the series.
      # posts - The array of posts in this series.
      def initialize(site, title, posts)
        @site = site
        @posts = posts
        @title = title
        @config = site.config["jekyll-series"]

        # Generate slug for the title
        @slug = Utils.slugify(title)

        # Save the generated file information
        @ext = File.extname(relative_path)
        @path = relative_path
        @name = File.basename(relative_path, @ext)

        @data = {
          "layout" => layout,
        }
        @content = ""
      end

      def title
        @title
      end

      def layout
        @config["layout"]
      end

      def permalink
        data && data.is_a?(Hash) && data["permalink"]
      end

      def url
        @url ||= URL.new({
            :template => "series/:name.html",
            :placeholders => { :name => @slug },
            :permalink => nil
          }).to_s
      rescue ArgumentError
        raise ArgumentError, "Template provided is invalid."
      end

      def relative_path
        path = URL.unescape_path(url).gsub(%r!^\/!, "")
        path
      end

      def inspect
        "#<Jekyll:SeriesPage @title=\"#{@title}\">"
      end
    end

    class Series < Jekyll::Generator
      safe true

      DEFAULTS = {
        "layout" => "series"
      }.freeze

      def initialize(config = nil)
        @config = Utils.deep_merge_hashes(DEFAULTS, config.fetch("jekyll-series", {}))
      end

      # The provided generate method performs 3 steps:
      #   1. It resolves the configuration settings
      #   2. It processes each series archive
      #   3. It stores each series archive as a new page and in site.config.
      def generate(site)
        @site = site
        @posts = site.posts
        @series = []

        @site.config["jekyll-series"] = @config

        process
        @site.pages.concat(@series)
        @site.config["series"] = @series
      end

      # To process each series, loop over the series and create a new series
      # page from it.
      def process
        series.each do |s, posts|
          @series << SeriesPage.new(@site, s, posts) unless s.nil?
        end
      end

      # Use Jekyll's site method 'post_attr_hash' to create an array of posts
      # grouped by the 'series' tag in each post's frontmatter.
      def series
        @site.posts.docs.group_by { |p| p.data['series'] }
      end
    end
  end
end
