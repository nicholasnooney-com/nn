---
layout: post
title: "Making Cambre: a voxel-based open-world game"
date: 2019-02-01 13:56:26 -0500
category: code
tags: [cpp, opengl]
series: "Cambre"
---

In my day-to-day work, I don't get to work too much with user-facing code. Such
is the world of embedded programming. So I decided to start a new project to
explore a different aspect of software. I also want to seriously consider the
architecture of this project, so not all of the posts will be directly related
to the implementation of the project. Lastly, I want to have fun making this
project, because otherwise there's no point.

<!-- excerpt separator -->

An important reason I write for this site is to share the knowledge that I
gained while doing this project. At the time of writing this, I'm still deciding
upon a system of feedback and updating the content.

# The Project

I would like to make a Minecraft-inspired clone. It will be a 3D voxel game
where I can explore an expansive world. I have some ideas that I would like to
try that would distinguish this from Minecraft itself, and I'll describe those
at the time I develop them.

I did a project in college working with OpenGL. I know that the OpenGL standard
is being deprecated for the newer Vulkan standard (or if you're Apple, the Metal
standard), but none of those have a good knowledgebase yet and I don't want to
deal with that. So I'm going to use OpenGL for the graphics context.

## A Sidetrack Into OpenGL

OpenGL is a API for communications between a Central Processing Unit (CPU) and
a Graphics Processing Unit (GPU). The OpenGL specification does not describe an
implementation; this is because the API is implemented at various levels in
hardware and software. A graphics vendor (Nvidia, Intel, AMD) will create a GPU
and provide a driver to access it. Each graphics vendor provides their own
driver specific calls that don't necessarily represent the OpenGL API (often
they include proprietary extensions) and application developers don't want to
provide many different builds of their application for each individual driver.
The role of translating between OpenGL calls and driver-specific calls is
performed by an OpenGL framework.

OpenGL frameworks are available on different systems:

- Linux: Provided by the Mesa 3D Graphics Library.
- MacOS: Provided by Apple's OpenGL Framework.
- Windows: Provided by Microsoft in the Windows SDK.

# Libraries and Technologies

Using OpenGL is a large design decision, but it also represents only a single
facet of this project: Graphics Rendering. I'll also need to handle user input,
provide audio support, and use a networking library to make it multiplayer. For
now, I'll decide upon a user-input library (which also handles window creation),
and I'll decide on the others later.

In college, we used `GLUT` to handle window creation and capturing user Input.
However, in the time since I've learned about `GLFW`. Both provide the same
functionality: creating a window and allowing me to respond to input; however, I
prefer to use `GLFW` because it provides more control over the application
structure than using `GLUT`. I can write my own game loop this way.

I also need an extension-management library so I can make the most out of my
GPU. For this, I'll use `GLEW`. And I want to use a math library for performing
linear algebra operations easily. For that, I'll use `GLM`.

This project uses the following libraries:

- GLFW (This library automatically includes Apple's OpenGL framework).
- GLEW
- GLM

# Grab a Copy

If you would like to see the code as it has evolved, check it out on
[GitHub][github-repo].

[github-repo]: https://github.com/nnooney/cambre
