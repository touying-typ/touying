---
sidebar_position: 4
---

# Code Style

## Simple Style

If we only need simplicity, we can directly input content under the heading, just like writing a normal Typst document. The heading here serves to divide the pages, and we can use commands like `#pause` to achieve animation effects.

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.simple.register()
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/f5bdbf8f-7bf9-45fd-9923-0fa5d66450b2)

You can use an empty heading `==` to create a new page. This skill also helps clear the continuation of the previous title.

PS: We can use the `#slides-end` marker to signify the end of `#show: slides`.

## Block Style

Many times, using simple style alone cannot achieve all the functions we need. For more powerful features and clearer structure, we can also use block style in the form of `#slide[...]`. The `#slide` function needs to be unpacked using the syntax `#let (slide, empty-slide) = utils.slides(s)` to be used correctly after `#show: slides`.

For example, the previous example can be transformed into:

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.simple.register()
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

#slide[
  Hello, Touying!

  #pause

  Hello, Typst!
]
```

and `#empty-slide[]` to create an empty slide without header and footer.

There are many advantages to doing this:

1. Many times, we not only need the default `#slide[...]` but also special `slide` functions like `#focus-slide[...]`.
2. Different themes' `#slide[...]` functions may have more parameters than the default, such as the university theme's `#slide[...]` function having a `subtitle` parameter.
3. Only `slide` functions can use the callback-style content block to achieve complex animation effects with `#only` and `#uncover` functions.
4. It has a clearer structure. By identifying `#slide[...]` blocks, we can easily distinguish the specific pagination effects of slides.

## Convention Over Configuration

You may have noticed that when using the simple theme, using a level-one heading automatically creates a new section slide. This is because the simple theme registers an `s.methods.touying-new-section-slide` method, so Touying will automatically call this method.

If we don't want it to automatically create such a section slide, we can delete this method:

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.simple.register()
#(s.methods.touying-new-section-slide = none)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/17a89a59-9491-4e1f-95c0-09a22105ab35)

As you can see, there are only two pages left, and the default section slide is gone.

Similarly, we can register a new section slide:

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.simple.register()
#(s.methods.touying-new-section-slide = (self: none, section, ..args) => {
  self = utils.empty-page(self)
  (s.methods.touying-slide)(self: self, section: section, {
    set align(center + horizon)
    set text(size: 2em, fill: s.colors.primary, style: "italic", weight: "bold")
    section
  }, ..args)
})
#let (init, slides, touying-outline) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/5305efda-0cd4-42eb-9f2e-89abc30b6ca2)

Similarly, we can modify `s.methods.touying-new-subsection-slide` to do the same for `subsection`.

In fact, besides `s.methods.touying-new-section-slide`, another special `slide` function is the `s.methods.slide` function, which will be called by default in simple style when `#slide[...]` is not explicitly used.

Also, since `#slide[...]` is registered in `s.slides = ("slide",)`, the `section`, `subsection`, and `title` parameters will be automatically passed, while others like `#focus-slide[...]` will not automatically receive these three parameters.

:::tip[Principle]

In fact, you can also not use `#show: slides` and `utils.slides(s)`, but only use `utils.methods(s)`, for example:

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.simple.register()
#let (init, touying-outline, slide) = utils.methods(s)
#show: init

#slide(section: [Title], title: [First Slide])[
  Hello, Touying!

  #pause

  Hello, Typst!
]
```

Here, you need to manually pass in `section`, `subsection`, and `title`, but it will have better performance, suitable for cases where faster performance is needed, such as when there are more than dozens or hundreds of pages.

:::