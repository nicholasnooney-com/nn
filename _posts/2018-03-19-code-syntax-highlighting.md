---
layout: post
title: "Code Syntax Highlighting"
date: 2018-03-19 11:09:40 -0400
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
---

One aspect of this static site that was looking bland was the code snippets
first presented in [Customizing This Site][post-link]. Originally, these
snippets were presented as black text on a grey background. To improve the
visual appearance of code blocks, I decided to add code syntax highlighting
with [Nord][nord-link].

<!-- excerpt separator -->

Jekyll supports SASS to compile CSS by default. Thankfully, Nord exports its
syntax coloring as SASS variables already. Jekyll also supports syntax
highlighting via rouge. Rouge is a ruby gem that is capable of parsing many
different languages and adding syntax highlighting to them. The resulting HTML
from Rouge uses the `.highlight` class to represent the formatted code.

In order to apply the Nord syntax highlighting to the Rouge output, I created a
SASS file that maps the styles to the Nord colors. The mapping file can be
found [here][style-link]. The result is the syntax highlighting you see
throughout this site!

[nord-link]: https://arcticicestudio.github.io/nord/
[post-link]: {{ site.baseurl }}{% link _posts/2018-01-21-customizing-this-site.md %}
[style-link]: <https://github.com/nnooney/jekyll-theme-nn/blob/master/_sass/_highlight.scss>
