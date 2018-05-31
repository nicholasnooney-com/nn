---
layout: post
title: "Adding Support for a Series of Posts"
date: 2018-03-08 09:45:52 -0500
category: web
tags: jekyll-theme this-site
series: "Developing a Custom Theme"
---

Sometimes, it makes sense to relate posts in a series. A continuation of a story
or an expansion of a project are all reasons to continue a post. This post is
part of the series *Developing a Custom Theme*, which details all of the
steps that resulted in the creation of this site's theme.

There are small differences between a post in a series and a post that is not
part of a series. The only difference to cause a normal post to become a part of
a series is to include the special tag `series:` in the front matter of the
post. The value of this tag is a string containing the name of the series. All
posts that contain the same value become grouped into the same series.

For posts belonging to a series, such as this one, you notice
a link to the series underneath the post header information. It has the nice,
italicized text _Part of the Series_. It also includes the series name as a link
to the series page. We'll cover the specifics of the series page in a later
post, but the markup to make the series identifier is fairly straightforward.
All of the markup is included below:

```html
<!-- _layouts/post.html -->
{% raw %}
{% if page.series %}
    {% include components/series-header.html %}
{% endif %}
{% endraw %}
```

```html
{% raw %}
<!-- _includes/components/series-header.html -->
{% assign series_page = page.series | slugify | append: ".html" %}

<section class="series-header level">
    <div class="level-left">
    </div>
    <div class="level-right">
        <p class="series-header is-italic">
            Part of the series
            <a href="{{ series_page | prepend: "/series/" | relative_url }}"
                class="link-wrapper-inline">
                <span class="has-text-info has-text-weight-semibold">
                    {{ page.series }}
                </span>
            </a>
        </p>
    </div>
</section>
{% endraw %}
```

In the post template, we add a section to include this new component if the
markup that Jekyll processes contains the `series:` tag inside the front matter.
This section of code belongs just before the post content. The component
contains some Bulma markup and a link to the series page. To get the name of the
series page, I take the series tag and pass it through a filter to get a
readable url and append _html_ to the end of the name.

In addition to the markup identifying that this post is a part of a series, I
also want the reader to be able to navigate through the series very easily. To
do this, I decided to add navigational markup to the bottom of the post. The
markup will allow the user to easily access the following items related to the
series:

- Another link to the series page
- The first post in the series
- The previous post in the series
- The next post in the series
- The last post in the series

Bulma's pagination component was perfect for displaying all of this information.
However, figuring out how to obtain all of the information via Jekyll was a bit
complicated. I'll try my best to explain it below.

Similar to how I handled the series header above, I created a new component to
handle all of the navigational information. This time, however, the excerpt is
inserted immediately after the post content.

```html
<!-- _layouts/post.html -->
{% raw %}
{% if page.series %}
    {% include components/series-footer.html %}
{% endif %}
{% endraw %}
```

This new component contains the following skeleton code:

```html
{% raw %}
<hr>
<section class="series-footer">
    <div class="level">
        <div class="level-item">
            <a href="{{ series_page | prepend: "/series/" | relative_url }}"
                class="link-wrapper">
                {% include components/feather-icon.html
                    icon="archive" class="has-text-info" %}
                <!-- Use this span for spacing -->
                <span class="icon"></span>
                <p class="has-text-info has-text-weight-semibold is-size-5">
                    {{ page.series }}
                </p>
            </a>
        </div>
    </div>
    <nav class="pagination is-centered" role="navigation"
        aria-label="pagination">
            <a href="{{ prev_url }}" class="pagination-previous">Previous</a>

            <a href="{{ next_url }}" class="pagination-next">Next</a>

        <ul class="pagination-list">
            <li>
                <a href="{{ first_url }}" class="pagination-link"
                    aria-label="Goto page 1">
                    1
                </a>
            </li>

            <li>
                <span class="pagination-ellipsis">&hellip;</span>
            </li>

            <li>
                <a href="{{ prev_url }}" class="pagination-link"
                    aria-label="Goto page {{ index | minus: '1' }}">
                    {{ index | minus: '1' }}
                </a>
            </li>

            <li>
                <a class="pagination-link is-current"
                    aria-label="Current page {{ index }}">
                    {{ index }}
                </a>
            </li>

            <li>
                <a href="{{ next_url }}" class="pagination-link"
                    aria-label="Goto page {{ index | plus: '1' }}">
                    {{ index | plus: '1' }}
                </a>
            </li>

            <li>
                <span class="pagination-ellipsis">&hellip;</span>
            </li>

            <li>
                <a href="{{ last_url }}" class="pagination-link"
                    aria-label="Goto page {{ count }}">
                    {{ count }}
                </a>
            </li>

        </ul>
    </nav>
    <div class="level">
        <div class="level-left">
            <p>
                <span class="is-hidden-tablet is-italic">Previous: </span>
                {{ prev_title }}
            </p>
        </div>
        <div class="level-right">
            <p>
                <span class="is-hidden-tablet is-italic">Next: </span>
                {{ next_title }}
            </p>
        </div>
    </div>
</section>
{% endraw %}
```

This code may seem overwhelming at first, so let's break it down. I define a
`section` to contain all of the series navigation, which contains three sub
elements. The first item contains the code for the link to the series page.
The second item is Bulma's pagination component that displays all of the buttons
for navigating throughout the series. The final component is another level that
displays the title of the previous and next post beneath the corresponding
navigational buttons.

The first element, which links to the series page, uses the same url scheme as
the series-header component. This time however, I center the text and include an
archive icon to indicate that this footer contains links to the series.

The second element contains the markup for the Bulma Pagination component. It
features the previous and next buttons, as well as links to the first, previous,
next, and last posts in the series. The two liquid variables `index` and `count`
contain numbers indicating the post's number in the series and the total number
of posts in the series, respectively. I'll show the logic how to calculate those
values below.

The third element contains Bulma markup which has been used throughout the site
before. The variables `prev_title` and `next_title` contain the titles of the
previous and next post. They are calculated in the logic below as well.

Before I show the rest of the liquid logic, it is important to understand all of
the markup that we are trying to show. I will make substantial modifications to
portions of that code to introduce new logic based upon which post in the series
is currently being viewed. For instance, it doesn't make sense to show a
previous post if the first post in the series is being viewed.

In order to calculate which posts belong to a series, it is necessary to loop
over all of the posts that Jekyll knows about. Liquid can help us out here:

```html
{%raw %}
{% assign count = '0' %}
{% assign index = '0' %}
{% assign capture_prev = true %}
{% assign capture_next = false %}

{% for post in site.posts reversed %}
    {% if post.series == page.series %}
        {% capture count %}{{ count | plus: '1' }}{% endcapture %}
        {% assign last_url = post.url %}

        {% if capture_next %}
            {% assign next_title = post.title %}
            {% assign next_url = post.url %}
            {% assign capture_next = false %}
        {% endif %}

        {% if post.url == page.url %}
            {% capture index %}{{ count }}{% endcapture %}
            {% assign capture_prev = false %}
            {% assign capture_next = true %}
        {% endif %}

        {% if capture_prev %}
            {% assign prev_title = post.title %}
            {% assign prev_url = post.url %}
        {% endif %}

        {% if count == '1' %}
            {% assign first_url = post.url %}
        {% endif %}
    {% endif %}
{% endfor %}
{% assign after = count | minus: index %}
{% endraw %}
```

I've presented all of the code up front. You can see at the beginning I assign
the variables `count` and `index`, as well as two helper variables,
`capture_prev` and `capture_next`. I use these two variables to help record
information about the previous and next post in the series. Then I loop over
each post. By default, Jekyll loops over posts starting with the most recent;
however, for numbering the posts in the series, I want to keep track of them in
chronological order. Therefore, I loop over them with the `reversed` keyword.

If the post belongs to the same series as the page (in this instance, page is
the current page being rendered while post is the collection of all posts on
this site), then I increment the count of pages. Every step after that in this
loop records information based upon which post is encountered. Interestingly,
for the correct behavior to emerge, I collect information in the opposite order
as the posts are presented.

To get the last post url, I always overwrite the variable `last_url`. This way,
by the end of the for loop, `last_url` is guaranteed to contain the url of the
last post in the series.

To get the next post url, I wait until I reach the current post and set the
`capture_next` variable to true. Then on the next iteration of the for loop, I
store the post title and url and reset the `capture_next` variable to false.
This helper variable, which goes from off to on and back to off again allows me
to capture the post immediately after the current post.

When I encounter the current post, I record the current count as the `index`.
I also set `capture_next` to true and `capture_prev` to false. This affects the
capture of the next and previous post information.

To get the previous post url, I capture every post while `capture_prev` is true.
Once I reach the current post, I set `capture_prev` to false in order to stop
recording the previous information.

To get the first post url, I record the information when the count is 1.

By the time the for loop exits, I have the urls of the first, previous, next,
and last post in the series. I also have the total count of posts and the index
of the current post. I also create the variable after, which records the number
of posts after the current post in the series. Now I need to use this
information to control which buttons should be available for the series
navigation. We'll revisit each of the sections in the navigational buttons and
use these variables to control what to show.

```html
{% raw %}
<hr>
<section class="series-footer">    
    ...

    <nav class="pagination is-centered" role="navigation"
        aria-label="pagination">
        {% if index > '1' %}
            <a href="{{ prev_url }}" class="pagination-previous">Previous</a>
        {% else %}
            <a href="{{ prev_url }}" class="pagination-previous" disabled>
                Previous
            </a>
        {% endif %}

        {% if after > 0 %}
            <a href="{{ next_url }}" class="pagination-next">Next</a>
        {% else %}
            <a href="{{ next_url }}" class="pagination-next" disabled>
                Next
            </a>
        {% endif %}

        <ul class="pagination-list">
            {% if index > '2' %}
            <li>
                <a href="{{ first_url }}" class="pagination-link"
                    aria-label="Goto page 1">
                    1
                </a>
            </li>
            {% endif %}

            {% if index > '3' %}
            <li>
                <span class="pagination-ellipsis">&hellip;</span>
            </li>
            {% endif %}

            {% if index > '1' %}
            <li>
                <a href="{{ prev_url }}" class="pagination-link"
                    aria-label="Goto page {{ index | minus: '1' }}">
                    {{ index | minus: '1' }}
                </a>
            </li>
            {% endif %}

            <li>
                <a class="pagination-link is-current"
                    aria-label="Current page {{ index }}">
                    {{ index }}
                </a>
            </li>

            {% if after > 0 %}
            <li>
                <a href="{{ next_url }}" class="pagination-link"
                    aria-label="Goto page {{ index | plus: '1' }}">
                    {{ index | plus: '1' }}
                </a>
            </li>
            {% endif %}

            {% if after > 2 %}
            <li>
                <span class="pagination-ellipsis">&hellip;</span>
            </li>
            {% endif %}

            {% if after > 1 %}
            <li>
                <a href="{{ last_url }}" class="pagination-link"
                    aria-label="Goto page {{ count }}">
                    {{ count }}
                </a>
            </li>
            {% endif %}

        </ul>
    </nav>
    <div class="level">
        <div class="level-left">
            {% if index > '1' %}
            <p>
                <span class="is-hidden-tablet is-italic">Previous: </span>
                {{ prev_title }}
            </p>
            {% endif %}
        </div>
        <div class="level-right">
            {% if after > 0 %}
            <p>
                <span class="is-hidden-tablet is-italic">Next: </span>
                {{ next_title }}
            </p>
            {% endif %}
        </div>
    </div>
</section>
{% endraw %}
```

The code above represents the same code as above, but with conditional logic for
showing the controls. The first thing to notice is the previous and next
buttons. If there is not a previous or next post, then those buttons are
disabled. I chose to make them disabled rather than hidden so that the flow of
the page is not affected by the post index. This creates a more consistent
interface, which I prefer.

Each of the buttons are shown dependent on the index of the post and the total
number of posts. It turns out that each button is dependent on the following
values:

- First post: `index > 2`. In order to show the first post, there must be more
  than one previous post.
- Previous ellipsis: `index > 3`. I show ellipses to indicate the existence of
  a post between the first and previous. Therefore, there must be a third post
  before the current post.
- Previous post: `index > 1`. There must be a previous post to show it.
- Next post: `after > 0`. There must be a next post to show it.
- Next ellipsis: `after > 2`. As with the previous ellipsis, I need to show it
  if there are three or more posts after the current post.
- Last post: `after > 1`. There must be more than one next post in order to show
  the last post.

The previous and next titles follow the same logic as the previous and next
post.

This logic leads to the desired behavior shown on each post. It can be a lot to
take in, so it may be more helpful to see the source of the components
discussed.

- [Series Header][series-header]
- [Series Footer][series-footer]

[series-header]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_includes/components/series-header.html
[series-footer]: https://github.com/nnooney/jekyll-theme-nn/blob/master/_includes/components/series-footer.html
