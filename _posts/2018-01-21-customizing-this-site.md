---
layout: post
title: "Customizing the Design of this Site"
date: 2018-01-21 22:56:26 -0500
category: web
tags: jekyll-theme, this-site
series: "Developing a Custom Theme"
---

The default Jekyll Site uses the `minima` theme. This theme is great for getting
started with the basic content of the site, but I prefer to know what's going
on behind the curtain. What exactly does Jekyll use to convert my markdown files
into a complete static site? To learn about this, I made a custom theme for this
site. The theme's source code is posted on [GitHub][theme-github].

Jekyll uses Ruby Gems to store themes. A theme is a collection of named HTML
files with [Liquid][liquid-docs] markup to insert the site content. The behavior
of each HTML/Liquid template can be controlled using front matter in each site
file. This front matter is also the way that Jekyll knows which template file to
use - the `layout` keyword indicates which HTML file to render. Overall, the
process looks like this:

1. The site file specifies a layout in its front matter.
2. Jekyll parses the site file and stores the file in named [variables][vars].
3. Jekyll loads the appropriate HTML template from the theme. The template file
   gets loaded with the variables parsed in step 2.
4. The fully rendered HTML file is saved in a build directory, which defaults
   to `_site`.

This is the main process that Jekyll runs through to generate a static website
from a series of HTML files. All of the plugins available for Jekyll will alter
how an individual step in the process is completed; however, the overall
process is the same.

As an example, let's go through step-by-step how this page is rendered. You can
view the source of this page [here][page-source]. Notice the layout's front
matter specifies the `post` layout; therefore, Jekyll will look for the file
`post.html` to convert the source to HTML. You can view `post.html` for this
site's theme [here][template-source].

The first thing to notice is that `post.html` specifies the `default` layout in
its own front matter. Just like markdown files can include front matter, theme
files can also contain front matter. The rendering engine is the same as well;
Jekyll will take the contents of `post.html` and will place it in the `content`
variable of `default.html`. With nested templates, it is possible to break down
complex page layouts into easy-to-read layout files.

The custom theme for this site uses several layout components to compose all of
the pages. Every page is based off of the `default` layout, which includes a
header, body, and footer. There are also optional layouts that can be included
on a per-page basis by setting variables in a page or post's front matter. The
hero banner on the front page and the category menu are examples of optional
layouts. These optional layouts are included with the liquid tag
`{% raw %}{% include %}{% endraw %}`.

This site currently has three different layouts: `post`, `page`, and `front`.
This post is rendered using the `post` layout, as specified previously. The
homepage uses the `front` layout. The About page is an example of the `page`
layout. As I discover the need for more types of layouts, I will add them to
this site and detail how they work.

A final note about the site's theme: the design of this site uses [Bulma][bulma]
to manage layout and styling. While its not the most flexible CSS framework,
available, it does provide plenty of customization and allows me to focus on
the content. The documentation is extensive and provides detailed examples of
how to structure the site's HTML. Take a look at Bulma's documentation if you
would like to understand the specifics of each layout.

[theme-github]: https://github.com/nnooney/jekyll-theme-nn
[liquid-docs]: https://shopify.github.io/liquid/
[vars]: https://jekyllrb.com/docs/variables/
[page-source]: https://github.com/nnooney/nn/blob/master/_posts/2018-01-21-customizing-the-design-of-this-site.md
[template-source]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_layouts/post.html
[bulma]: https://bulma.io
