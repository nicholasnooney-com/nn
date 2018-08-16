---
layout: post
title: "Customizing the Design of this Site"
date: 2018-01-21 22:56:26 -0500
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
---

The default Jekyll Site uses the `minima` theme. This theme is great for getting
started with the basic content of the site, but I prefer to know what's going
on behind the curtain. What exactly does Jekyll use to convert my markdown files
into a complete static site? To learn about this, I made a custom theme for this
site. The theme's source code is posted on [GitHub][theme-github].

<!-- excerpt separator -->

### How do Jekyll Themes Work?

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
site's theme [here][layout-post].

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

### The Layouts of this Theme

In order to fully explain how this theme was developed, I will explain how I
built the layouts included in this theme. Currently, my goal for this theme is
to obtain feature parity with the `minima` theme. In future posts in this
series, I will explain how these basic themes changed to fit my needs.

#### default.html

Every theme starts with a base layout. This layout will contain the core
identity that all other layouts will tweak. In this theme, the base layout is
`default.html`. Like all HTML documents, it starts with the base document
layout:

```html
{% raw %}
<!DOCTYPE html>
<html>
{% include head.html %}
<body>
</body>
</html>
{% endraw %}
```

I've separated the `<head>` content into a separate template, `head.html`. This
is to keep all of the information belonging to the head of the document in its
own place.

It's also good to describe the language of the document. This is done via the
`lang` attribute on the `<html>` tag.

```html
{% raw %}
<html lang="{{ page.lang | default: site.lang | default: 'en' }}">
{% endraw %}
```

Use the page language first, falling back to the site language if the page
doesn't specify a language, and using English if neither are specified.

Many websites have a header and a footer. This site is no exception. However,
we'll separate the header and the footer into separate templates like with the
header above. Also, we'll use a `<section>` tag for the main content.

```html
{% raw %}
<body>
    {% include header.html %}
    <section>
        {{ content }}
    </section>
    {% include footer.html %}
</body>
{% endraw %}
```

Now it's time to format the layout. I decided with this theme to use a single
column layout to focus on the content with an optional sidebar menu. To make the
menu optional, the template must specify `menu: true` in its YAML Front Matter
to include the menu. The `front` layout does this below. Anyways, here is what
the main content looks like, expanded upon the section tags in the previous
excerpt.

```html
{% raw %}
<section class="section">
    <div class="container">
        {% if layout.menu %}
        <div class="columns">
            <div class="column is-narrow">
                {% include components/menu.html %}
            </div>
            <div class="column">
        {% endif %}
                <main class="page-content" aria-label="Content">
                    <div class="wrapper">
                        {{ content }}
                    </div>
                </main>
        {% if layout.menu %}
            </div>
        </div>
        {% endif %}
    </div>
</section>
{% endraw %}
```

All of the classes here except for the main tag are part of [Bulma][bulma]. Look
through the documentation there to see how each class contributes to the overall
layout.

One more snippet makes the default layout complete: an optional hero banner.
This banner adds a splash of color and can be seen on the front page of the
website. Like the menu, it too must be specified with `hero: true` in order to
be activated. Since it should appear at the top of the page, it appears between
the header and the `<section>` tag. This snippet sets up the hero banner:

```html
{% raw %}
{% if layout.hero %}
    {% include components/hero.html %}
{% endif %}
{% endraw %}
```

Altogether, this code makes for a customizable default template that suits the
needs of this site. The full code for this template is available
[here][layout-default].

#### post.html

The `post` template defines the main content for posts (including this one). As
specified in the introduction, this template inherits the `default` template
via the front matter.

```html
{% raw %}
---
layout: default
---

<article class="post">
</article>
{% endraw %}
```

This will cause all of the contents of the `post` layout to be inserted into the
`{% raw %}{{ content }}{% endraw %}` tag of the `default` layout. We can inherit
the head, header, and footer from the default template. Since the post content
is the primary focus, this template will not include the optional hero or menu
template.

There are two parts to the `post` layout: the header and the content. The header
is the most complex. It contains the post title, date, and tags. There's a bit
of Bulma styling here to make it render nicely as well.

```html
{% raw %}
<section class="post-header">
    <div class="level">
        <div class="level-left">
            <header class="post-title">
                <p class="title is-3 has-text-primary">
                    {{ page.title | escape }}
                </p>
                <p class="subtitle is-5">
                    {{ page.date | date: "%B %-d, %Y" }}
                </p>
            </header>
        </div>
        <div class="level-right">
            <div class="tags">
                {% for tag in page.tags %}
                <span class="tag is-light">{{ tag }}</span>
                {% endfor %}
            </div>
        </div>
    </div>
</section>

<hr>
{% endraw %}
```

The header is a combination of Bulma layout and Jekyll specific Liquid tags, and
so is the content.

```html
{% raw %}
<section class="post-content">
    <div class="content">
        {{ content }}
    </div>
</section>
{% endraw %}
```

The `post` layout is heavily focused on text. In a future iteration I hope to
add better support for images and other media types as well. You can see the
full code of the post template [here][layout-post].

#### page.html

The `page` template is identical to the `post` layout, except it can specify a
long-title to use instead of the normal title. This is due to the fact that any
page with a title by default gets added to the navigation bar in the header of
the site. Below is the content of the `page` template:

```html
{% raw %}
<article class="page">
    <div class="level">
        <div class="level-left">
            <header class="page-header">
                <p class="title is-3 has-text-primary">
                    {{ page.long-title | default: page.title | escape }}
                </p>
                <p class="subtitle is-5">
                    {{ page.date | date: "%B %-d, %Y" }}
                </p>
            </header>
        </div>
        <div class="level-right">
            <div class="tags">
                {% for tag in page.tags %}
                <span class="tag is-light">{{ tag }}</span>
                {% endfor %}
            </div>
        </div>
    </div>
    <hr>
    <div class="content">
        {{ content }}
    </div>
</article>
{% endraw %}
```

You can see the full code of the page template [here][layout-page].

#### front.html

The `front` layout is designed to be the homepage of this website. It's intent is to
provide a helpful summary of the site's content and serve as an entry point to explore
the rest of the site. It's layout is quite different from the `page` and `post`
templates. To start, its front matter does include the optional hero and menu
components.

```yaml
{% raw %}
---
layout: default
hero: true
menu: true
---
{% endraw %}
```

Other than that, the `front` layout is very simple. It defines a `<section>` to
contain the main content, and then kicks off to include a series of the most recent
posts.

```html
{% raw %}
<section class="front">
    {{ content }}
</section>

{% include components/recent-posts.html %}
{% endraw %}
```

The `recent-posts` component lists the most recent posts in the site. In fact, its
layout is very similar to the header of the `post` template. The noticeable difference
is the additional liquid logic: it performs additional checks to add a horizontal line
between posts, and it limits the tags displayed to three.

```html
{% raw %}
<section class="recent-posts">
    {% for post in site.posts %}
        <article class="media">
            <div class="media-content">
                <div class="content">
                    <div class="level">
                        <div class="level-left">
                            <div class="wrapper">
                                <p class="title is-4">
                                    <a href="{{ post.url | relative_url }}">
                                        {{ post.title | escape }}
                                    </a>
                                </p>
                                <p class="subtitle is-6">
                                    {{ post.date | date: "%b %-d, %Y" }}
                                </p>
                            </div>
                        </div>
                        <div class="level-right">
                            <div class="tags">
                                {% for category in post.categories %}
                                <span class="tag is-info">
                                    {{ category | escape }}
                                </span>
                                {% endfor %}
                                {% for tag in post.tags %}
                                <span class="tag is-light">
                                    {{ tag | escape }}
                                </span>
                                {% if forloop.index > 3 %}
                                    {% break %}
                                {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
                    <div class="post-excerpt">
                        {{ post.excerpt }}
                    </div>
                </div>
            </div>
        </article>
        {% if forloop.last == false %}
            <hr>
        {% endif %}
    {% endfor %}
</section>
{% endraw %}
```

You can see the full code of the front template [here][layout-front].

### Summary

These code snippets make up a complete Jekyll theme. I did not show the `head`,
`header`, and `footer` includes that the default template uses. It is worthwhile to
have a look at those as well to gain a complete understanding of how the site fully
works. You can view the theme's source on [GitHub][theme-github].

Over the course of these series of posts, I will introduce additional features to
customize the theme further. All of the code in this theme is under the
[MIT License][theme-license] and can be customized to suit your needs.

[theme-github]: https://github.com/nnooney/jekyll-theme-nn
[liquid-docs]: https://shopify.github.io/liquid/
[vars]: https://jekyllrb.com/docs/variables/
[page-source]: https://github.com/nnooney/nn/blob/master/_posts/2018-01-21-customizing-this-site.md
[layout-post]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_layouts/post.html
[bulma]: https://bulma.io
[layout-default]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_layouts/default.html
[layout-page]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_layouts/page.html
[layout-front]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_layouts/front.html
[theme-license]: https://github.com/nnooney/jekyll-theme-nn/blob/master/LICENSE.txt
