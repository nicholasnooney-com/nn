---
layout: post
title: "Managing this Site with Rake"
date: 2018-03-07 22:40:25 -0500
category: web
tags: this-site
---

In order to remember how to correctly build this site, I decided to use `Rake`.
Rake is Ruby's version of Make: by specifying targets to build and how to build
them, I can easily perform a complex series of commands to manage this site.
Because Rake is so versatile in declaring targets, I use it to create new posts,
run continuous integration, and even generate SSL Certificates for my local
development environment.
