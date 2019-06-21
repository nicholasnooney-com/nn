# A Plugin that will generate an archive page for any group of posts.
# group: key in the post's frontmatter.
require "jekyll"

module Jekyll
  module Groupby
    class GroupbyPage < Jekyll::Page
      attr_accessor :posts, :slug
      attr_reader :group, :title, :layout, :config

      # Attributes for Liquid templates. Every member in this array is
      # accessible to use in the layout file for the rendered page.
      ATTRIBUTES_FOR_LIQUID = %w(
        posts
        group
        title
        slug
        name
        path
        url
        permalink
        config
      ).freeze

      # Initialize a new Groupby Page. Here we setup all the member variables
      # of the page so that it can be accessed and processed by Jekyll.
      #
      # site - The Site object.
      # title - The value of the key being grouped.
      # config - The specific configuration for this page
      # posts - The array of posts in this group.
      def initialize(site, title, config, posts)
        @site = site
        @title = title
        @config = config
        @posts = posts

        Jekyll.logger.debug "Page:", " ... #{title}"

        # Generate slug for the title
        @slug = Utils.slugify(title)

        # Store a reference to liquid variables.
        @layout = @config["layout"]
        @group = @config["name"]

        # Save the generated file information
        @ext = File.extname(relative_path)
        @path = relative_path
        @name = File.basename(relative_path, @ext)

        @data = {
          "layout" => layout,
        }
        @content = ""
      end

      def permalink
        data && data.is_a?(Hash) && data["permalink"]
      end

      def url
        @url ||= URL.new({
            :template => @site.config["jekyll-groupby"]["permalink"],
            :placeholders => { :group => @group, :name => @slug },
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

      GROUP_DEFAULTS = {
        "name" => "",
        "layout" => "",
        "multiple" => false
      }.freeze

      def initialize(config = nil)
        @config = Utils.deep_merge_hashes(DEFAULTS, config.fetch("jekyll-groupby", {}))
      end

      # The provided generate method performs 3 steps:
      #   1. It processes each groupby archive
      #   2. It resolves the configuration settings
      #   3. It stores each groupby archive as a new page and in site.config.
      def generate(site)
        @site = site
        @posts = site.posts
        @group_pages = []

        Jekyll.logger.info  "Jekyll Groupby:", "Generating group pages"
        Jekyll.logger.debug "Jekyll Groupby:", "Begin Generation..."

        # Ensure expected config variables are present
        @site.config["jekyll-groupby"] = @config

        # 1. Process all of the posts; this function will populate the
        # group_pages array and update the configuration.
        process

        # 2. Save the updated config to the site's config.
        @site.config["jekyll-groupby"] = @config

        # 3. Add all of the group_pages to the site's pages so that they get
        # rendered by later stages in the Jekyll pipeline.
        @site.pages.concat(@group_pages)

        Jekyll.logger.debug "Jekyll Groupby:", "Generation complete!"
      end

      # To process each group archive, loop over each value and create a new
      # groupby page from it. Don't do it for groups of posts that do not have
      # the groupby key present.
      def process
        @config["groups"].each do |config|
          Jekyll.logger.debug "Group:", "Creating pages for \"#{config["name"]}\":"

          # Ensure the default variables are present in the config at the group
          # level.
          config = config.merge!(GROUP_DEFAULTS) { |k, v1, v2| v1 }

          # Use the groupBy method below to generate a hash where each entry in
          # the hash is a single member for the provided key and the values are
          # an array of posts containing that entry. See the groupBy function
          # below for more details.
          group_posts = groupBy(config["name"])

          # Using our hash, convert it to an array in order to support accessing
          # the config from liquid templates and sort the array by the names of
          # each entry. The sorting allows for alphabetical iteration of each
          # group.
          config["posts"] = group_posts.map {
            |k, v| { "name" => k, "list" => v }
          }.sort {
            |a, b| a["name"] <=> b["name"]
          }

          # For each value in the hash, create a group page.
          group_posts.each do |val, posts|
            @group_pages << GroupbyPage.new(@site, val, config, posts)
          end
        end
      end

      # Group each post by the 'key' argument. The key is the name of a front-
      # matter variable used to define a grouping. This will create an array of
      # posts with one entry for each value of the attribute encountered. Each
      # entry looks like this:
      #   {value: [Array of posts with that value]}
      #
      # For example, if there were three posts, A1, A2, and S1 belonging to the
      # "series" A and S respectively, this function would produce the following
      # output given the key "series":
      #   { "A": [A1, A2], "S": [S1] }
      # If there is a post P that does not have the "series" front-matter, then
      # it will not be included in the output hash.
      def groupBy(key)

        # What's happening here is we are accessing all posts. It turns out that
        # the Jekyll variable site.posts returns a Collection object containing
        # all posts in the site. We access the documents array of all the posts
        # because we need to access the front matter in order to determine which
        # key in the hash the post belongs to. We then filter the documents to
        # only those which contain the given key in the front-matter.
        filtered_posts = @site.posts.docs.select { |p| p.data.key?(key) }

        # Next we create a hash and add the post to each bucket in the hash with
        # the given value. If a post has multiple values for the key, then it
        # will end up in multiple buckets in the hash. This may be the case when
        # grouping by tags.
        @hash = Hash.new

        filtered_posts.each do |p|
          pval = p.data[key]

          if pval.nil?
            Jekyll.logger.debug "Post:", " !!! Skipping \"#{p.data["title"]}\""
            next
          elsif pval.is_a? Array
            pval.each do |val|
              addToHash(val, p)
            end
          else
            addToHash(pval, p)
          end
        end

        # Finally, return the hash that was created.
        @hash
      end

      # This helper method preserves the format of the hash, namely, that each
      # value is an array. When a new item is added, it is added to the array,
      # or a new array is created if the key does not yet exist in the hash.
      def addToHash(key, val)
        if not @hash.has_key?(key)
          @hash[key] = []
        end

        @hash[key] << val
      end
    end
  end
end
