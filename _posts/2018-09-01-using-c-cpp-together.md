---
layout: post
title: "Using C and C++ Together"
date: 2018-09-01
category: code
tags: [c, cpp]
---

This article describes how to write code that is available in both C and C++.
The [C++ website][isocpp] has a great FAQ section on how to mix C and C++; this
article shows a concrete example for implementation.

<!-- excerpt separator -->

The motivation behind this article is that at work we needed a better way to
write unit tests for our code base. Much of the logic was placed into stubbed
functions (we use Parasoft C++Test), which violated the principle of clear,
immediately understandable, test code. Therefore, we made a framework to control
the behavior of our stub functions from the test code itself. As a result, the
stubs became more similar, shorter, easier to understand, and easier to
maintain. This framework can be used to test both C and C++ code.

In order to succesfully compile a component that can be included and used in
both C and C++ code, the basic structure we found to work well consists of the
following components:

1. A common header file that all programs include to use the component.
2. A C++ specific header file for the C++ implementation.
3. A C++ implementation of the component.
4. A C specific header file for the C implementation.
5. A C-compatible wrapper for using the component.

Let me explain each of these parts in further detail.

## The Example Component

For the purpose of making this article easier to understand, we'll implement the
following component:

A counter module that can be used to count things. It supports the following
interface:
- `int counter(void)`: Register a new counter with a count of 0. Returns the id
  of the new counter.
- `int count(int ctr, int amt)`: Increment _ctr_ by _amt_. Returns the new count
  of _ctr_.
- `int reset(int ctr)`: Reset _ctr_ to 0. Returns the new count of _ctr_.

Notice that the specification uses only C-style functions. This is to ensure
that the component can be used in C code.

The files we'll create to implement this component will have the following
names:

1. `counter.h`: The common include header.
2. `counter_cpp.h`: The C++ header.
3. `counter_cpp.cpp`: The C++ implementation.
4. `counter_c.h`: The C header.
5. `counter_c.cpp`: The C wrapper.

Notice that the C wrapper is compiled with the C++ compiler. This is important
for allowing the wrapper to call the implemented functions.

## The Common Header

Although not strictly necessary, this common header file makes it easier for
all code to use the component. It makes use of the standard predefined compiler
macro `__cplusplus`. This macro is only defined for C++ compilers, which makes
it possible to redirect the code to include the appropriate header.

The implementation of the counter component would look like this:

```c++
// File counter.h
#ifdef __cplusplus
#include "counter_cpp.h"
#else
#include "counter_c.h"
#endif
```

## The C++ Header

If the component is used as a part of C++ code, then this header will be
included. Here we create the class spec for the counter component.

```c++
// File counter_cpp.h
#include <vector>

class Counter {
public:
  int counter(void);
  int count(int ctr, int amt);
  int reset(int ctr);
private:
  std::vector<int> mvCounters;
};
```

For brevity, I have omitted the constructors and destructor.

## The C++ Implementation

The C++ implementation contains the implementation for each of the functions in
the header. This is standard C++ with nothing fancy happening.

```c++
// File counter_cpp.cpp
#include "counter_cpp.h"

int Counter::counter(void) {
  mvCounters.push_back(0);
  return mvCounters.size();
}

int Counter::count(int ctr, int amt) {
  mvCounters[ctr] += amt;
  return mvCounters[ctr];
}

int Counter::reset(int ctr) {
  mvCounters[ctr] = 0;
  return mvCounters[ctr];
}
```

Any C++ code can include the header and begin using the implementation of the
counter component. Things get interesting when allowing the C code to access
the members of this class.

## The C Header

The C header defines the interface for C programs to use the component. Since
C++ code normally gets mangled, we use `extern "C"` to ensure that the code does
not get mangled and C code can properly resolve the symbols during linking. The
C header also uses a series of wrapper functions, since the class keyword is non
existent.

```c
/* File counter_c.h */

#ifdef __cplusplus
extern "C" {
#endif

int counter_counter(void);
int counter_count(int ctr, int amt);
int counter_reset(int ctr);

#ifdef __cplusplus
}
#endif
```

## The C Wrapper Implementation

The trick to making this work is that the C wrapper implementation is actually
compiled with a C++ compiler. This allows the C code to use the C++ class
implementation.

```c
// File counter_c.cpp
#include "counter_c.h"
#include "counter_cpp.h"

#ifdef __cplusplus
extern "C" {
#endif

Counter gCounterObj = Counter();

int counter_counter(void) {
  gCounterObj.counter();
}

int counter_count(int ctr, int amt) {
  gCounterObj.count(ctr, amt);
}

int counter_reset(int ctr) {
  gCounterObj.reset(ctr);
}

#ifdef __cplusplus
}
#endif
```

The C wrapper forwards each function called by the C code to the C++ object. In
this instance, a global object is used to facilitate access to the C++
implementation, but it could be also implemented by using a pointer to a
`Counter` instance and declaring a struct that can be used to pass Counter
objects around in C++ code.

# Wrapup

The ability to commingle C and C++ code has allowed us to avoid writing a
separate implementation of a component for use with a different compiler. This
pattern can be useful to work with different components. It can be extended to
support using many other patterns as well.

[isocpp]: https://isocpp.org/wiki/faq/mixing-c-and-cpp
