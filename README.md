# [Touying](https://github.com/touying-typ/touying) ![logo](https://github.com/touying-typ/touying/assets/34951714/2aa394d3-2319-4572-aef7-ed3c14b09846)

[Touying](https://github.com/touying-typ/touying) (投影 in chinese, /tóuyǐng/, meaning projection) is an object-oriented and efficient package for creating presentation slides in Typst.

Touying is a package derived from [Polylux](https://github.com/andreasKroepelin/polylux). Therefore, most concepts and APIs remain consistent with Polylux. You can refer to the [Polylux documentation](https://polylux.dev/book/) for a better understanding of Touying.

Compared to Polylux, Touying employs a more object-oriented writing style, capable of simulating **a mutable global singleton**. So, Touying can conveniently access and update "global variables", such as the 'handout-mode' boolean variable. At the same time, you can easily retrieve and modify page parameters by `self.page-args`, avoiding the side effects of creating a new page caused by `#set page(..)`.

Additionally, Touying does not rely on `locate` and `counter` for implementing `#pause`, thus offering better performance, albeit with certain limitations. The advantage is that you can use `#pause` inline. The drawback is that `#pause` after set-show rule won't take effect (you must use set-show rule in the `setting` parameter). Currently, `#pause` only works at the outermost level, and it won't work inside layout functions like grid, but you can use the `composer` parameter to add yourself layout function like `utils.side-by-side`.

**Warning: It is under development, and the API may change at any time.**

## Implemented Features

- [x] **Object-oriented programming:** Singleton `s`, binding methods `utils.methods(s)` and `(self: obj, ..) => {..}` methods.
- [x] **Page arguments management:** Instead of using `#set page(..)`, you should use `self.page-args` to retrieve or set page parameters, thereby avoiding unnecessary creation of new pages.
- [x] **`#pause` for sequence content:** You can use #pause at the outermost level of a slide, including inline and list.
- [x] **`#pause` for layout functions:** You can use the `composer` parameter to add yourself layout function like `utils.side-by-side`, and simply use multiple pos parameters like `#slide[..][..]`.
- [x] **Callback-style `uncover`, `only` and `alternatives`:** Based on the concise syntax provided by Polylux, allow precise control of the timing for displaying content.
  - You should manually control the number of subslides using the `repeat` parameter.
- [x] **Transparent cover:** Enable transparent cover using oop syntax like `#let s = (s.methods.enable-transparent-cover)(self: s)`.
- [x] **Handout mode:** enable handout mode by `#let s = (s.methods.enable-handout-mode)(self: s)`.
- [x] **Fit-to-width and fit-to-height:** Fit-to-width for title in header and fit-to-height for image.
  - `utils.fit-to-width(grow: true, shrink: true, width, body)`
  - `utils.fit-to-height(width: none, prescale-width: none, grow: true, shrink: true, height, body)`
- [x] **Slides counter:** `states.slide-counter.display() + " / " + states.last-slide-number` and `states.touying-progress(ratio => ..)`.
- [x] **Appendix:** Freeze the `last-slide-number` to prevent the slide number from increasing further.
- [x] **Sections:** Touying's built-in section support can be used to display the current section title and show progress.
  - [x] `states.new-section(section)` to register a new section.
  - [x] `states.current-section` to get the current section.
  - [x] `states.touying-outline` or `s.methods.touying-outline` to display a outline of sections.
  - [x] `states.touying-final-sections(sections => ..)` for custom outline display.
  - [x] `states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)` for powerful progress display.
- [x] **Pdfpc:** pdfpc support and export `.pdfpc` file without external tool by `typst query` command simply.


## Features to Implement

- [ ] **More themes:** Add more themes.
- [ ] **Combinable components**: Combinable components for header, footer and sidebar, .
- [ ] **Navigation bar**: Navigation bar like [here](https://tex.stackexchange.com/questions/350508/adding-outline-bar-to-the-beamer-for-section-mentioning) by `states.touying-progress-with-sections(..)`.
- [ ] **Document:** Add a more detailed document.
- [ ] **External viewers:** Integration with external viewers like impress.js and typst-preview.

Feel free to suggest any ideas and contribute.


## Dynamic slides

We can export `example.pdfpc` file by command `typst query --root . ./examples/example.typ --field value --one "<pdfpc-file>" > ./examples/example.pdfpc`

```typst
#import "../lib.typ": s, pause, utils, states, pdfpc, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
))
// #let s = (s.methods.enable-handout-mode)(self: s)
#let (init, slide, touying-outline) = utils.methods(s)
#show: init

// simple animations
#slide[
  a simple #pause dynamic

  #pause
  
  slide.
][
  second #pause pause.
]

// complex animations
#slide(setting: body => {
  set text(fill: blue)
  body
}, repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  in subslide #self.subslide

  test #uncover("2-")[uncover] function

  test #only("2-")[only] function

  #pause

  and paused text.
])

// multiple pages for one slide
#slide[
  #lorem(200)

  test multiple pages
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide[
  appendix
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/9365bbc4-9e9c-4a78-a1ab-1716d1bf22f2)


## Themes

```typst
#import "../lib.typ": s, pause, utils, states, pdfpc, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  author: [Authors],
  title: [Title],
  subtitle: [Subtitle],
  date: [Date],
  extra: [Extra],
)

#slide(title: [Table of contents])[
  #touying-outline()
]

#slide(title: [A long long long long long long long long long long long long long long long long long long long long long long long long Title])[
  A slide with some maths:
  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

#new-section-slide[First section]

#slide[
  A slide without a title but with #alert[important] infos
]

#new-section-slide[Second section]

#focus-slide[
  Wake up!
]

// simple animations
#slide[
  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, new-section-slide) = utils.methods(s)

#new-section-slide[Appendix]

#slide[
  appendix
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/f08dc948-68b4-45d6-8e87-53ca3fc9912c)


## Acknowledgements

Thanks to...

- [@andreasKroepelin](https://github.com/andreasKroepelin) for the `polylux` package
- [@Enivex](https://github.com/Enivex) for the `metropolis` theme
- [@ntjess](https://github.com/ntjess) for contributing to `fit-to-height`, `fit-to-width` and `cover-with-rect`
