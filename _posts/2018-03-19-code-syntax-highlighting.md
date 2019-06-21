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

Below are some examples of the results of syntax highlighting. These snippets
(and more) can be found [here][code-link].

#### C

```c
/* Hello World in C, Ansi-style */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  puts("Hello World!");
  return EXIT_SUCCESS;
}
```

#### C++

```c++
// Hello World in ISO C++

#include <iostream>

int main()
{
    std::cout << "Hello World!" << std::endl;
}
```

#### Go

```go
// Hello world in Go

package main
import "fmt"
func main() {
 fmt.Printf("Hello World\n")
}
```

#### Java

```java
// Hello World in Java

class HelloWorld {
  static public void main( String args[] ) {
    System.out.println( "Hello World!" );
  }
}
```

#### LLVM

```llvm
; Hello world in LLVM Assembly

@.str = internal constant [14 x i8] c"hello, world\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main(i32 %argc, i8** %argv) nounwind {
entry:
    %tmp1 = getelementptr [14 x i8]* @.str, i32 0, i32 0
    %tmp2 = call i32 (i8*, ...)* @printf( i8* %tmp1 ) nounwind
    ret i32 0
}
```

#### Python 3

```python
# Hello world in Python 3 (aka Python 3000)

print("Hello World")
```

#### Racket

```racket
;; Hello world in Racket

#lang racket/base
"Hello, World!"
```

#### Ruby

```ruby
# Hello World in Ruby

puts "Hello World!"
```

#### Shell Script

```sh
# Hello world for the Unix shells (sh, ksh, csh, zsh, bash, fish, xonsh, ...)

echo Hello World
```

[nord-link]: https://arcticicestudio.github.io/nord/
[post-link]: {{ site.baseurl }}{% link _posts/2018-01-21-customizing-this-site.md %}
[style-link]: <https://github.com/nnooney/jekyll-theme-nn/blob/master/_sass/_highlight.scss>
[code-link]: <https://helloworldcollection.de>
