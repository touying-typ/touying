---
sidebar_position: 11
---

# Creating Your Own Theme

Creating your own theme with Touying might seem a bit complex initially due to the introduction of various concepts. However, fear not; if you successfully create a custom theme with Touying, you'll likely experience the convenience and powerful customization features it offers. You can refer to the [source code of existing themes](https://github.com/touying-typ/touying/tree/main/themes) for guidance. The key steps to implement are:

- Customize the `register` function to initialize the global singleton `s`.
- Customize the `init` method.
- Define a color theme by modifying the `self.colors` member variable.
- Customize the `alert` method (optional).
- Customize the header.
- Customize the footer.
- Customize the `slide` method.
- Customize special slide methods, such as `title-slide` and `focus-slide`.
- Customize the `slides` method (optional).

To demonstrate creating a simple and elegant Bamboo theme, let's follow the steps.


## Modifying Existing Themes

If you wish to modify a theme within the Touying package locally instead of creating one from scratch, you can achieve this by following these steps:

1. Copy the [theme code](https://github.com/touying-typ/touying/tree/main/themes) from the `themes` directory to your local machine. For example, copy `themes/university.typ` to a local file named `university.typ`.
2. Remove all `#import "../xxx.typ"` commands at the top of the `university.typ` file.
3. Add `#import "@preview/touying:0.4.1": *` at the top of the `university.typ` file to import all modules.
4. Replace `self: s` in the `register` function with `self: themes.default.register()` **(Important)**.

You can then import and use the theme by:

```typst
#import "@preview/touying:0.4.1": *
#import "university.typ"

#let s = university.register(aspect-ratio: "16-9")
```

For a specific example, refer to: [https://typst.app/project/rqRuzg0keo_ZEB5AdxjweA](https://typst.app/project/rqRuzg0keo_ZEB5AdxjweA)


## Import

Depending on whether the theme is for personal use or part of Touying, you can import in two ways:

If for personal use:

```typst
#import "@preview/touying:0.4.1": *
```

If part of Touying themes:

```typst
#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"
```

Additionally, add the import statement in Touying's `themes/themes.typ`:

```
#import "bamboo.typ"
```


## Register Function and Init Method

Next, we'll distinguish between the bamboo.typ template file and the main.typ file, the latter of which is sometimes omitted.

Generally, the first step in creating slides is to determine font size and page aspect ratio. Therefore, we need to register an initialization method:

```typst
// bamboo.typ
#import "@preview/touying:0.4.1": *

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
) = {
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
  )
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}

// main.typ
#import "@preview/touying:0.4.1": *
#import "bamboo.typ"

#let s = bamboo.register(aspect-ratio: "16-9")
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]
```

As you can see, we created a `register` function and passed an `aspect-ratio` parameter to set the page aspect ratio. We get default `self` by `self: themes.default.register()`. As you might already know, in Touying, we should not use `set page(..)` to set page parameters but rather use the syntax `self.page-args += (..)` to set them, as explained in the Page Layout section.

In addition, we registered a `self.methods.init` method, which can be used for some global style settings. For example, in this case, we added `set text(size: 20pt)` to set the font size. You can also place additional global style settings here, such as `set par(justify: true)`. Since the `init` function is placed inside `self.methods`, it is a method, not a regular function. Therefore, we need to add the parameter `self: none` to use it properly.

As you can see, later in `main.typ`, we apply the global style settings in `init` using `#show: init`, where `init` is bound and unpacked through `utils.methods(s)`.

If you pay extra attention, you'll notice that the `register` function has an independent `self` at the end. This actually represents returning the modified `self` as the return value, which will be saved in `#let s = ..`. This line is therefore indispensable.

## Color Theme

Choosing an attractive color theme for your slides is crucial. Touying provides built-in color theme support to minimize API differences between different themes. Touying offers two dimensions of color selection: the first is `neutral`, `primary`, `secondary`, and `tertiary` for hue distinction, with `primary` being the most commonly used; the second is `default`, `light`, `lighter`, `lightest`, `dark`, `darker`, and `darkest` for brightness distinction.

As we are creating the Bamboo theme, we chose a color for the `primary` theme, similar to bamboo (`rgb("#5E8B65")`), and included neutral lightest/darkest as background and font colors.

As shown in the code below, we use `(self.methods.colors)(self: self, ..)` to modify the color theme. Essentially, it is a wrapper for `self.colors += (..)`.

```typst
#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
  )
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}
```

After adding the color theme, we can access the color using syntax like `self.colors.primary`.

It's worth noting that users can change the theme color at any time using:

```typst
#let s = (s.methods.colors)(self: s, primary: rgb("#3578B9"))
```

This flexibility demonstrates Touying's powerful customization capabilities.

## Practical: Custom Alert Method

In general, we need to provide a `#alert[..]` function for users, similar to `#strong[..]`. Typically, `#alert[..]` emphasizes text using the primary theme color for aesthetics. We add a line in the `register` function:

```typst
self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
```

This code sets the text color to `self.colors.primary`, utilizing the theme's primary color.

## Custom Header and Footer

Here, assuming you've already read the Page Layout section, we know we should add headers and footers to the slides.

Firstly, we add `self.bamboo-title = []`. This means we save the title of the current slide as a member variable `self.bamboo-title`, stored in `self`. This makes it easy to use in the header and later modifications. Similarly, we create `self.bamboo-footer`, saving the `footer: []` parameter from the `register` function for displaying in the bottom-left corner.

It's worth noting that our header is actually a content function in the form of `let header(self) = { .. }` with the `self` parameter, allowing us to get the latest information from `self`. For example, `self.bamboo-title`. The footer is similar.

The `components.cell` used inside is actually `#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)`, and `show: components.cell` is shorthand for `components.cell(body)`. The `show: pad.with(.4em)` in the footer is similar.

Another point to note is the `states` module, which contains many counters and state-related content. For example, `states.current-section-title` is used to display the current `section`, and `states.slide-counter.display() + " / " + states.last-slide-number` is used to display the current page number and total number of pages.

We observe the usage of `utils.call-or-display(self, self.bamboo-footer)` to display `self.bamboo-footer`. This is used to handle situations like `self.bamboo-footer = (self) => {..}`, ensuring a unified approach to displaying content functions and content.

To ensure proper display of the header and footer and sufficient spacing from the main content, we also set margins, such as `self.page-args += (margin: (top: 4em, bottom: 1.5em, x: 2em))`.

We also need to customize a `slide` method that accepts `slide(self: none, title: auto, ..args)`. The first `self: none` is a required method parameter for getting the latest `self`. The second `title` is used to update `self.bamboo-title` for displaying in the header. The third `..args` collects the remaining parameters and passes them to `(self.methods.touying-slide)(self: self, ..args)`, which is necessary for the Touying `slide` functionality to work properly. Additionally, we need to register this method in the `register` function with `self.methods.slide = slide`.

```typst
// bamboo.typ
#import "@preview/touying:0.4.1": *

#let slide(self: none, title: auto, ..args) = {
  if title != auto {
    self.bamboo-title = title
  }
  (self.methods.touying-slide)(self: self, ..args)
}

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  footer: [],
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  // variables for later use
  self.bamboo-title = []
  self.bamboo-footer = footer
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    states.current-section-title
    linebreak()
    set text(size: 1.5em)
    utils.call-or-display(self, self.bamboo-title)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.bamboo-footer)
    h(1fr)
    states.slide-counter.display() + " / " + states.last-slide-number
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 4em, bottom: 1.5em, x: 2em),
  )
  // register methods
  self.methods.slide = slide
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}


// main.typ
#import "@preview/touying:0.4.1": *
#import "bamboo.typ"

#let s = bamboo.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/d33bcda7-c032-4b11-b392-5b939d9a0a47)

## Custom Special Slide

Building upon the basic slide, we further add some special slide functions such as `title-slide`, `focus-slide`, and a custom `slides` method.

For the `title-slide` method, first, we call `self = utils.empty-page(self)`. This function clears `self.page-args.header`, `self.page-args.footer`, and sets `margin` to `0em`, creating a blank page effect. Then, we use `let info = self.info + args.named()` to get information stored in `self.info` and update it with the passed `args.named()` for later use as `info.title`. The specific page content `body` will vary for each theme, so we won't go into details here. Finally, we call `(self.methods.touying-slide)(self: self, repeat: none, body

)`, where `repeat: none` indicates that this page does not require animation effects, and passing the `body` parameter displays its content.

For the `new-section-slide` method, the process is similar. The only thing to note is that in `(self.methods.touying-slide)(self: self, repeat: none, section: section, body)`, we pass an additional `section: section` parameter to declare the creation of a new section. Another point to note is that besides `self.methods.new-section-slide = new-section-slide`, we also register `self.methods.touying-new-section-slide = new-section-slide`, so `new-section-slide` will be automatically called when encountering a first-level title.

For the `focus-slide` method, most of the content is similar, but it's worth noting that we use `self.page-args += (..)` to update the page's background color.

Finally, we update the `slides(self: none, title-slide: true, slide-level: 1, ..args)` method. When `title-slide` is `true`, using `#show: slides` will automatically create a `title-slide`. Setting `slide-level: 1` indicates that the first-level and second-level titles correspond to `section` and `title`, respectively.

```
// bamboo.typ
#import "@preview/touying:0.4.1": *

#let slide(self: none, title: auto, ..args) = {
  if title != auto {
    self.bamboo-title = title
  }
  (self.methods.touying-slide)(self: self, ..args)
}

#let title-slide(self: none, ..args) = {
  self = utils.empty-page(self)
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
    )
    set text(fill: self.colors.neutral-darkest)
    if info.author != none {
      block(info.author)
    }
    if info.date != none {
      block(if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
    }
  }
  (self.methods.touying-slide)(self: self, repeat: none, body)
}

#let new-section-slide(self: none, section) = {
  self = utils.empty-page(self)
  let body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", style: "italic")
    section
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: section, body)
}

#let focus-slide(self: none, body) = {
  self = utils.empty-page(self)
  self.page-args += (
    fill: self.colors.primary,
    margin: 2em,
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let slides(self: none, title-slide: true, slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  footer: [],
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  // variables for later use
  self.bamboo-title = []
  self.bamboo-footer = footer
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    states.current-section-title
    linebreak()
    set text(size: 1.5em)
    utils.call-or-display(self, self.bamboo-title)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.bamboo-footer)
    h(1fr)
    states.slide-counter.display() + " / " + states.last-slide-number
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 4em, bottom: 1.5em, x: 2em),
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.slides = slides
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}


// main.typ
#import "@preview/touying:0.4.1": *
#import "bamboo.typ"

#let s = bamboo.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, focus-slide) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]

#focus-slide[
  Focus on it!
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/03c5ad02-8ff4-4068-9664-d9cfad79baaf)


## Conclusion

Congratulations! You've created a simple and elegant theme. Perhaps you may find that Touying introduces a wealth of concepts, making it initially challenging to grasp. This is normal, as Touying opts for functionality over simplicity. However, thanks to Touying's comprehensive and unified approach, you can easily extract commonalities between different themes and transfer your knowledge seamlessly. You can also save global variables, modify existing themes, or switch between themes effortlessly, showcasing the benefits of Touying's decoupling and object-oriented programming.