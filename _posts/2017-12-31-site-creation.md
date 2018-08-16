---
layout: post
title: "The Creation of this Site"
date: 2017-12-31
category: web
tags: this-site
---

So I just setup a new blog for myself, and after looking at the numerous options
for publishing content on the web, I decided a static site would suit my needs
best. I don't imagine this site will grow to large numbers, and I don't plan on
hosting huge amounts of media (big pictures and large video files). Plus I've
dealt with WordPress enough to know that I don't want to stray anywhere near
that beast of a CMS. But mostly, being the programmer that I am, I find managing
a simple repository with files containing all of the necessary information for
this site much easier than throwing everything into a database and tweaking the
inner workings of that. Operating Systems are better suited to handle files and
folders rather than databases.

<!-- excerpt separator -->

So after searching around on the Internet to find the static site generator that
was simple enough that I could comprehend how everything works behind the scenes
(I like exploring how things work), I settled on Jekyll. Hugo was a close second
but I decided I wanted to get some exposure to Ruby over Go. That and GitHub has
first class support of Jekyll sites and will publish them for you.

I did however, want a snazzy domain name for my site, and since most people in
tech need a web presence, I decided to purchase my own. I didn't need any
hosting package (thanks GitHub), so I purchased a domain name from NameCheap.
About $50 for 5 years. Not too bad.

With a domain name and hosting through GitHub, I was ready to go. All I had to
do was install Ruby and Jekyll, and publish my repository to GitHub. With the
help of several guides, I able to set up this site exactly how I wanted to. I
followed these guides in roughly the steps outlined:

1. [Setup Jekyll][step-1] to create a site on my local PC.
2. Publish the repository to GitHub (I don't have a guide for this step, since
   I've published several repositories to GitHub before). By default, GitHub
   uses the `master` branch. I also published an identical `gh-pages` branch
   which I chose to host from.
3. [Enable GitHub Pages][step-3] to host the `gh-pages` branch of the repo.
4. [Create a CNAME Record][step-4] with NameCheap to point to the static site. I
   only needed to create the CNAME record; I didn't create any other records in
   this tutorial.

After I got the generic site to show up, I wanted to integrate some continuous
integration steps into my site. Travis CI has first class support for continuous
integration of GitHub repositories, so it naturally made sense to include that.
Thankfully, Jekyll includes a [great tutorial][step-5] to setup continuous
integration with Travis CI.

Windows Note: the `htmlproofer` gem needs `libcurl.dll` to run successfully. It
does not come prepackaged with the gem. To solve this, I downloaded curl for
Windows and moved the file `libcurl.dll` to `C:/Ruby24-x64/bin`. This will allow
the local execution of the CI script.

With that, I had a properly functioning static site configured, with a custom
domain and continuous integration set up.

- Website Source: GitHub
- Domain Name: NameCheap
- Hosting: GitHub Pages
- Continuous Integrations: Travis CI

#### Some Time Later

I discovered Netlify, which provides free hosting of static sites (similar to
GitHub) and it contains its own continuous integration system. Although I
already have a functional static site, I decided to switch over to Netlify
hosting and continuous integration. I am a fan of using fewer services when
possible so that I don't forget about all the places that I need to visit to
maintain my site.

To transition the previous site over to Netlify, I needed to first disable
hosting via GitHub Pages. This was as simple as removing the CNAME file and
deleting entries from the settings tab of the repository. Once I did that, I
signed up with Netlify (via GitHub), and created a site for my repository.
Finally, I updated the CNAME record at NameCheap to point to the Netlify URL
rather than the GitHub pages URL.

I also needed to update the Continuous integration from using Travis CI to using
Netlify's built in CI. Also, while the short tutorial to set up CI is nice, it
lacks a few resources that are important to modern build systems: separate
environments, dependency-based builds, and better automated testing. However,
since it is easier to develop locally than test via pushing to the remote, I
want to be able to run the complete set of tests both locally and when I push.
Therefore, I want to introduce Rake as a better build system.

Rather than use a bash script to kick off the continuous integration, I now use
`rake deploy` as my deployment. After updating the build command with Netlify, I
have a full site up and running.

- Website Source: GitHub
- Domain Name: NameCheap
- Hosting: Netlify
- Continuous Integration: Netlify

[step-1]: https://jekyllrb.com/docs/quickstart/
[step-3]: https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/
[step-4]: https://www.namecheap.com/support/knowledgebase/article.aspx/9645/2208/how-do-i-link-my-domain-to-github-pages
[step-5]: https://jekyllrb.com/docs/continuous-integration/travis-ci/
