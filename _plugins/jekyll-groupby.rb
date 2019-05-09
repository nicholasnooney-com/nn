# A Plugin that will generate an archive page for any group of posts.
# series: key in the post's frontmatter.
require "jekyll"

module Jekyll
  module Groupby
    class GroupbyPage < Jekyll::Page
      attr_accessor :posts, :slug

      # Attributes for Liquid templates
      ATTRIBUTES_FOR_LIQUID = %w(
        posts
        title
        key
        slug
        name
        path
        url
        permalink
      ).freeze

      # Initialize a new Groupby Page
      #
      # site - The Site object.
      # title - The value of the key being grouped.
      # key - The name of the key being grouped.
      # posts - The array of posts in this series.
      def initialize(site, title, key, posts)
        @site = site
        @posts = posts
        @title = title
        @key = key
        @config = site.config["jekyll-groupby"]

        Jekyll.logger.info "Jekyll Groupby:", " ... #{title}"

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

      def key
        @key
      end

      def slug
        @slug
      end

      def layout
        @config["groups"][@key]["layout"]
      end

      def permalink
        data && data.is_a?(Hash) && data["permalink"]
      end

      def url
        @url ||= URL.new({
            :template => @config["permalink"],
            :placeholders => { :group => @key, :name => @slug },
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
        "#<Jekyll:GroupbyPage @path=\"#{@path}\">"
      end
    end

    class Groupby < Jekyll::Generator
      safe true

      DEFAULTS = {
        "permalink" => ":group/:name.html",
        "groups" => []
      }.freeze

      def initialize(config = nil)
        @config = Utils.deep_merge_hashes(DEFAULTS, config.fetch("jekyll-groupby", {}))
      end

      # The provided generate method performs 3 steps:
      #   1. It resolves the configuration settings
      #   2. It processes each groupby archive
      #   3. It stores each groupby archive as a new page and in site.config.
      def generate(site)
        @site = site
        @posts = site.posts
        @group_pages = []

        Jekyll.logger.info "Jekyll Groupby:", "Begin Generation..."

        @site.config["jekyll-groupby"] = @config
        process
        @site.pages.concat(@group_pages)

        Jekyll.logger.info "Jekyll Groupby:", "Generation complete!"
      end

      # To process each group archive, loop over each value and create a new
      # groupby page from it. Don't do it for groups of posts that do not have
      # the groupby key present.
      def process
        @config["groups"].each do |key, config|

          Jekyll.logger.info "Jekyll Groupby:", "Creating pages for \"#{key}\":"

          groupBy(key).each do |val, posts|
            @group_pages << GroupbyPage.new(@site, val, key, posts) unless val.nil?
          end
        end
      end

      # Group each post by the 'key' argument. This will create an array of
      # posts with one entry for each value of the attribute encountered. Each
      # entry looks like this:
      #   {value: [Array of posts with that value]}
      def groupBy(key)
        @site.posts.docs.group_by { |p| p.data[key] }
      end
    end
  end
end
