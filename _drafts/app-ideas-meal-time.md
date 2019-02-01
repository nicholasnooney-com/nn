---
layout: post
title: "App Ideas: Meal Time"
date: 2017-12-31
categories: app-idea
tags: meal-time
---

# Introduction

Mealtime is an application meant to assist in creating a meal from multiple
recipes. It will organize the steps of multiple recipes into a coherent set of
directions that will allow all of the parts of the meal to be ready at the same
time. Some of the additional features of the app are:

- Dinner Time. Set exactly what time you want dinner to be ready, and the recipe
  will let you know when you need to begin cooking. It will also allow you to
  scale the recipe to the number of diners attending.
- Multi-Chef Mode. When there are two chefs in the kitchen, twice the number of
  steps can be performed. The app will present each chef's work in a
  side-by-side view so that the chefs can work side-by-side in the kitchen.
- Analytic Cooking. After cooking several recipes, the app will learn how you
  cook and adjust recipe preparation and cooking times based upon how much time
  you take to perform a step in a recipe. For example, if you take on average
  three minutes to dice an onion, the recipe will adjust the preparation time to
  show how long it takes you to chop an onion.

## Special Secondary Features

- Share Mode. Share your recipes with friends and family on all major social
  media platforms. Discover meals via those sites and easily import them into
  your cookbook.
- Cookbook sync. Keep your cookbook synced between all your devices.
- Plan Mode. Plan the meals you want to make for any amount of time in advance.
  Summarize several meals into a shopping list of ingredients. Partner with
  other entities to discover coupons for items on your shopping list.
- Dinner Time Extended. Take a meal and format it into a nice recipe that can be
  printed or electronically transferred to those who dine with you.
- Professional Mode. See exact portions, cost per portion, and other more
  detailed information that Grandma doesn't need to see when baking her famous
  chocolate chip cookies.
- TV Mode. Making a recipe that you saw on TV? Can it be watched online? Then
  it can be made in Mealtime. Each step of the recipe will allow you to play the
  corresponding portion of the TV show that the host made the recipe with, as
  many times as you need to see exactly how they did it.
- Recipe importer. Using Natural Language Processing, read the text of the
  recipe and convert it to the appropriate format for the application.

# Prior Art

## PepperPlate

PepperPlate provides many of the same features that would be integrated into
this app. It provides a 'Cook Mode' that allows multiple recipes to be made
simultaneously. However, the integrations between steps is lacking; it only
allows for one global timer to be set while viewing only one recipe at a time.

# Inspiration

## Google Maps

Google Maps provides an intuitive UI for determining exactly how to get from
point A to point B. With it's step-by-step directions, traffic analysis, and
clear UI, it makes travelling as easy as possible. For Mealtime, point A happens
to be a collection of ingredients and point B happens to be a beautiful meal.

# Technical Details

## Recipe Format

This app will require a special format for storing recipes so that the app can
reorder steps and create a coherent recipe.
