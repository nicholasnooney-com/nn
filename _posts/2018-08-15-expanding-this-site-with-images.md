---
layout: post
title: "Expanding this Site with Images"
date: 2018-08-15 21:07:43 -0400
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
featured-image: tahoe.jpg
featured-alt: "Lake Tahoe"
---

{% include components/featured-image.html %}

In order to make the site stand out, and also to support media types most
common to the internet, I've quickly styled up a featured image container. This
code uses the assets plugin, and results in a simple styled image at the
beginning of each post.

<!-- excerpt separator -->

- Adding `jekyll-assets`
- Creating `components/featured-image.html`
- CSS Tweaks
- Addtional Front Matter `featured-image` `featured-alt`
- Excerpt Separator
