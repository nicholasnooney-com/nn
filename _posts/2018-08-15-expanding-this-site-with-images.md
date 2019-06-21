---
layout: post
title: "Expanding this Site with Images"
date: 2018-08-15 21:07:43 -0400
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
featured-image:
    src: tahoe.jpg
    alt: "Lake Tahoe"
---

In order to make the site stand out, and also to support media types most
common to the internet, I've quickly styled up a featured image container. This
code uses the assets plugin, and results in a simple styled image at the
beginning of each post.

<!-- excerpt separator -->

The images themselves are inserted via the [jekyll-assets][jekyll-assets]
plugin. The snippet of code that renders them using the assets plugin looks
like this:

```html
{% raw %}
<div class="featured-image-container">
  <figure>
    <div class="box">
      {% if include.post.featured-image.src %}
      {% asset
          "{{ include.post.featured-image.src }}"
          magick:resize=400x400>
          alt="{{ include.post.featured-image.alt }}" %}
      {% endif %}
    </div>
  </figure>
</div>
{% endraw %}
```

The `asset` liquid tag comes courtesy of `jekyll-assets`. It allows me to resize
the image via [ImageMagick][imagemagick] so that the images don't end up too
large, and it uses the variables in the `featured-image` front matter to
determine the source and alt text for the image. I've put this code in a
component called `featured-image.html`. Any post can include it and provide the
necessary variables to use a featured image. Including the featured image from
a post looks like this:

```html
---
featured-image:
    src: tahoe.jpg
    alt: "Lake Tahoe"
---

<div class="content">
    {% include components/featured-image.html post=page %}
</div>
```

I've added this html snippet to the `post` layout as well as the `post-snippet`
component so that any post can include it for free. It's also interesting to
note that this is the first template that requires a variable to be passed into
it. By default when processing a post, Jekyll stores all information about the
post, including its front-matter, in the variable called `page`. The template
passes the page variable into the component `featured-image.html`. All the
variables passed via the `include` liquid tag get stored in the variable called
`include` (fitting, huh?). That is why the YAML front-matter is referenced as
`include.post.featured-image` instead of just `post.featured-image`.

To get the image just right, I needed to tweak a few CSS properties of Bulma.
The current method I use to organize the styling in this theme is via a main
`assets/nn.scss` file. It looks like this:

```scss
---
# This file needs front matter in order for Jekyll to process Sass
---

@import "nn-main";
```

This is a dummy file that imports another SASS file called `nn-main.scss`. That
serves as the main entrypoint for the styling of the theme. The reason I have
an additional import is so that I can separate the styles as they would be
organized in a main SASS project from the portion required to make Jekyll
process the styles.

Anyways, back to the style changes that needed to be tweaked. I created another
SASS file called `_bulma-tweaks.scss` that gets imported by `nn-main.scss`. This
file is where I can place all the custom rules to override Bulma as much as I
need. Here's the change I made for the `featured-image`:

```css
.featured-image-container {
    display: flex;
    justify-content: center;
}
```

This just makes sure that the image shows up in the center of the containing
box. There was one last thing missing that I hadn't realized up to this point:
when I looked at the front page of the site, I noticed that all the text for
posts that included this image went missing. The root cause of this is how
Jekyll determines what an excerpt should look like. Because the `featured-image`
component added extra HTML, Jekyll thought that was sufficient for the excerpt
and removed the text. Thankfully, there's a way to get it back. Jekyll considers
a config variable called `excerpt_separator:` when determining how to make post
excerpts. Defining the variable in the file `_config.yml` will cause Jekyll to
consider all text before the matching string the post excerpt.

```yaml
excerpt_separator: <!-- excerpt separator -->
```

I've backfilled this comment in all earlier posts and updated the Rakefile to
generate a post with an excerpt separator so that I always have control over
where to split the post. With all of these small changes in place, I am able to
include images in a more pleasing manner.

In the future, I plan to add a way to view the full-size original asset as well
as include images throughout the post. This `featured-image` component provides
a great starting point for all this future work.

[jekyll-assets]: https://github.com/envygeeks/jekyll-assets
[imagemagick]: https://imagemagick.org/index.php
