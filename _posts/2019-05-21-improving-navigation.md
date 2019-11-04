---
layout: post
title: "Improving Navigation"
date: 2019-05-21 13:23:52 -0400
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
---

The original menu on the front page was lacking. It only contained a list of the
categories of each post I've written. However, after adding support for series
of posts, I think it would be nice to show the series' titles in the menu as
well. This required making a custom plugin `jekyll-groupby` and the creation of
a new layout called `group` to display groups of items. The result of the code
in this post leads to the menu on the sidebar.

<!-- excerpt separator -->

Eariler in the development of this site, I added support for a series of posts,
which allowed me to provide controls to navigate from post to post within a
series. However, I still lacked a way to see all of the posts that belong to a
series in a readable manner. I also cannot view all the posts belonging to a
category or tag (which we'll see later is similar to viewing all of the posts
in a series).

I've also never worked with plugins to modify content in Jekyll static sites.
The [documentation][1] contains several examples of what can be done with
plugins, including generating content (which will be used here to create landing
pages for each of the series, categories, and tags). The result of this post is
the plugin `jekyll-groupby`, which allows for dynamic configuration of groups of
posts.

Since I have never programmed in Ruby before, I based my plugin off of the
existing plugin [jekyll-archives][2]. This plugin allows for creation of achives
by date, tag, and category. The plugin itself consists of two parts: a custom
page class to store information pertaining to the generated page, and a custom
generator used to construct a page and populate it with content from the site's
data. My plugin will also use this structure.

# Implementing the Plugin

The plugin is implemented as a single Ruby source file and placed in the
`_plugins` directory in the website's source tree. I found this to be the
easiest method (other methods supported by Jekyll require the plugin to be
installed as a Ruby gem).

The Jekyll documentation describes that a Generator must define a function
`generate` that is provided an instance of the site. By modifying the variable
`site.pages`, it is possible to generate any new content for a site. The page
can use Jekyll's existing layout system to create the layout; this plugin needs
to provide details about the posts that belong to a particular series or
category or tag.

To begin this plugin, I want to look at the configuration used in `_config.yml`.
A look at the configuration describes the settings I've arrived at and need to
implement.

```yaml
jekyll-groupby:
  permalink: ":group/:name.html"
  groups:
    - name: "series"
      layout: "group"
    - name: "category"
      layout: "group"
    - name: "tags"
      layout: "group"
```

The top-level key is the name of the plugin. This is a common theme when using
plugins so that a `_config.yml` file can organize all of it's settings. Inside
this hash are two keys `permalink` and `groups`. The `permalink` describes how
to format the URLs for this generated page. It uses the placeholders `:group`,
which is the name of the group ("series", "category", "tag"), and `:name`, which
is the name of an item in the group ("code" or "web" for the group "category").
The `groups` key is an array of objects that provide the name of each group and
the layout used to format the group page. The site currently uses three groups,
each with the same layout `group` (which is shown later).

The structure of this config can provide context for implementing the generator.
What we need to do is loop over each object in `groups`, and for each object,
find the posts that use that group and divide them into lists by group. This is
best shown with an example; we'll use this set of posts (available via
`site.posts` as an example for the plugin):

| # | post              | category  |
|---|-------------------|-----------|
| 1 | C++ overview      | code      |
| 2 | Chrome vs Firefox | web       |
| 3 | Python 2 and 3    | code      |
| 4 | Javascript        | code, web |
| 5 | WebSockets        | web       |

The groupby page will generate pages for each category, and each page will show
a list of posts with the matching category. The plugin will use a Generator and
Page in order to create the category pages. With the example site above, there
are 2 generated pages: `/category/code` and `/category/web`. Each page will
contain a list of posts belonging to that category, accessible via the variable
`page.posts`. This is the reason we need a custom Page class instead of using
Jekyll's default Page class; with our custom class, we can provide any of the
data that we want to provide for rendering with liquid templates.

# The Page Class

Below is the source for the Page class.

```ruby
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
  end
end
```

The class itself is scoped within a special namespace to avoid collisions with
other Ruby code that runs during the generation process. The most important
function is the `initialize` function. It accepts the title (item in a group,
such as "code" and "web"), config (the object with "name" and "layout"), and
a list of posts belonging to that category. All of the other functions provide
variables that can be used to access data in the page when it is time to render
it.

# The Generator Class

Below is the source for the generator class.

```ruby
module Jekyll
  module Groupby
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
```

The Generator peforms the following actions (beginning with the `generate`
function): Grab the configuration from `_config.yml`, organize `site.posts` by
category and return a dictionary of posts for each category, then loop through
the dictionary and create a Page for each category. After all the pages are
generated, they are added to `site.pages` so that they appear in the final
output.

# The Group Layout

Below is the code for the `group` layout.

```html
{% raw %}
---
layout: default
---

{% comment %}
This template works closely with the groups used by the plugin jekyll-groupby.
{% endcomment %}

<p class="title is-2 has-text-info">
    {{ page.title }}
</p>
<p class="subtitle is-6">
    {% assign num_posts = page.posts | size %}
    {{ num_posts }}
    {% if num_posts > 1 %}
        posts
    {% else %}
        post
    {% endif %}
    {% if site.data[page.group].matchline %}
        {{ site.data[page.group].matchline }}
    {% else %}
        in this {{ page.group }}
    {% endif %}
</p>

{% assign group_data = site.data[page.group].items | where: "name", page.slug
    | first %}
{% if group_data %}
<p class="content">
    {{ group_data.content }}
</p>
<hr>
{% endif %}

<section class="posts-group">
    {% for post in page.posts %}
        {% include components/post-snippet.html post=post %}

        {% if forloop.last == false %}
            <hr>
        {% endif %}
    {% endfor %}
</section>
{% endraw %}
```

The layout uses `page.posts` to display an excerpt of each post in the category
via the component `post-snippet`, which was created previously for the front
page. The large amount of liquid templates provide the correct verbiage for
the page materials. Some of it is also customizable via YAML [data files][3].
Specifically, a paragraph can be added to describe the group and the subtitle
can be customized via the variable `matchline`. Here is an example of the data
used to customize a `series` page on my site (in the file `_data/series.yml`).

```yaml
matchline: "in this series"
items:
  - name: developing-a-custom-theme
    content: >
      This series of posts details the process I completed to design the theme
      for this site. I began exploring how gem-based themes work and build a
      working theme that contains feature-parity with Minima, Jekyll's default
      theme. I then move on to add more advanced content, including supporting a
      series of posts, adding Code Syntax Highlighting, and other features to
      complement the theme of this site. As I update the theme, I will add more
      posts to this series. You can always grab the latest copy of this theme's
      code at GitHub.
```

# Wrapping It Up

With this flexible system, I can display any related group of posts on a single
page. This greatly improves discoverability and allows for viewing the bigger
picture of related content on my site.

[1]: https://jekyllrb.com/docs/plugins/
[2]: https://github.com/jekyll/jekyll-archives
[3]: https://jekyllrb.com/docs/datafiles/
