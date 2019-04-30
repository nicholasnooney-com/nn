---
layout: post
title: "Cambre: An exploration into RAII"
date: 2019-04-29 20:57:22 -0400
category: code
tags: [cpp, opengl]
series: "Cambre"
---

In the previous introduction to Cambre, I mentioned that I would be using
`GLFW`, `GLEW`, and `GLM` for handling different aspects of the program. These
libraries are great, but I would also like to use a recent C++ version to
organize the code I write. Because the three aforementioned libraries are all
C style libraries, that means that I have to do a little bit of extra wrangling
in order to make them fit my application's organization.

<!-- excerpt separator -->

Every program begins with a `main` function, so let's get started there:

```c++
int main()
{
    return 0;
}
```

Great! We have a program that we can run. It is even more basic than a "Hello,
World!" program, but it does work. Next we need to initialize the libraries in
order to make use of them throughout our application. Let's expand `main` to
create the libraries.

```c++
#include <iostream>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

int main()
{
    if (!glfwInit())
    {
        std::cout << "GLFW Initialization Failure" << std::endl;
        return 1;
    }

    GLFWwindow *window;
    window = glfwCreateWindow(800, 800, "Cambre", NULL, NULL);

    if (!window)
    {
        std::cout << "GLFW Window Creation Failure" << std::endl;
        return 1;
    }

    glfwMakeContextCurrent(window);

    if (GLEW_OK != glewInit())
    {
        std::cout << "GLEW Initialization Failure" << std::endl;
        return 1;
    }

    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();
    }

    return 0;
}
```

This is the basics of creating a window with `GLFW` and initializing `GLEW`. It
is a bit of extra work to get this to compile; another post in this series will
detail the build system that is used to compile the final executable. This post
refers just to the code required to build the program. If you are unsure about
what is happening here, the best place to find out is the
[GLFW documentation][glfw-docs]. The [GLEW documentation][glew-docs] explains
how to get started with the GLEW library.

But wait just one second. This code isn't neatly wrapped inside the paradigm of
C++ and object oriented design. What can we do to make that work? The key is to
place this code inside of the constructor so that when we create an instance of
that object, the code is initialized for us. There is a caveat in this approach,
however. Because we are moving the code here to the constructor of an object, we
may end up in a situation where the code is executed multiple times. Depending
on the external calls, this may or may not be the desired behavior. If the code
supports being called multiple times, then it is said to be reentrant. If it is
not, then we need to introduce another pattern in order to ensure the code is
executed only once.

In order to place this code into a constructor, we need to create a class that
will hold the code. Let's call it `Application`. Here is the defintion of the
class:

```c++
#ifndef _CAMBRE_APPLICATION_H_
#define _CAMBRE_APPLICATION_H_

#include <GL/glew.h>
#include <GLFW/glfw3.h>

class Application
{
public:

    Application(void);
    ~Application(void);
    void run(void);

private:

    GLFWwindow *mpWindow;
};

#endif
```

There's not too much to it! We provide a constructor and destructor, and a `run`
function. This will be the entrypoint into the while loop of the code above. It
makes sense to split these because the step of initialization should be separate
from the step of running the program. Below are the implementations of each
method.

```c++
#include <iostream>

#include "Application.hpp"

Application::Application(void)
{
    if (!glfwInit())
    {
        std::cout << "GLFW Initialization Failure" << std::endl;
    }

    mpWindow = glfwCreateWindow(800, 800, "Cambre", NULL, NULL);

    if (!mpWindow)
    {
        std::cout << "GLFW Window Creation Failure" << std::endl;
    }

    glfwMakeContextCurrent(mpWindow);

    if (GLEW_OK != glewInit())
    {
        std::cout << "GLEW Initialization Failure" << std::endl;
    }
}
```

For the constructor, we copied the code in the main function above, replacing
the local function variable `window` with the class member `mpWindow`. This
allows us to keep a reference to the window as the object is used. Also notice
that we can no longer return an error code from the constructor in the event of
a failure. To do this, we need to come up with some other mechanism for
preventing the code from continuing to construct an Application if an error
occurs. That mechanism will be described in a later post.

Now let's move onto the `run` method.

```c++
void Application::run(void)
{
    while (!glfwWindowShouldClose(mpWindow))
    {
        glfwPollEvents();
    }
}
```

The `run` method for now contains the loop that will be executed over and over
while the application is still running. We will eventually expand upon this to
include all of the game's logic and functionality.

We've covered all of the code from the previous `main` function, but we still
have the destructor to write! Actually, it is a good idea to clean up the window
once we are done with it, which we didn't do before. That's a good fit for the
destructor of this class; whenever an `Application` object goes out of scope,
its destructor is called, automatically cleaning up the window's memory.

```c++
Application::~Application(void)
{
    glfwDestroyWindow(mpWindow);

    glfwTerminate();
}
```

With all of the logic moved outside of our `main` function, it becomes very
simple to run the program! All we need to do is create an `Application` object
and call its `run` method. Once the `main` function exits, the resources used
by the `Application` object will automatically be cleaned up via the destructor.

```c++
#include "Application.hpp"

int main()
{
    Application app;

    app.run();

    return 0;
}
```

Voila! This is the beauty of RAII, or "Resource Acquisition is Initialization".
By constructing (think initializing) the `Application` object, I've implicitly
acquired a window to run the program in.

So what's next? We still need to figure out how to handle errors in the
constructor of the `Application` class, and it would be great to see some stuff
drawn to the window.

[glfw-docs]: https://www.glfw.org/documentation.html
[glew-docs]: http://glew.sourceforge.net/basic.html
