---
sidebar_position: 9
---

# Build Your Own Theme

Creating your own theme with Touying can be a bit complex due to the many concepts we've introduced. But rest assured, if you do create a theme with Touying, you might deeply appreciate the convenience and powerful customizability that Touying offers. You can refer to the [source code of the themes](https://github.com/touying-typ/touying/tree/main/themes). The main things you need to implement are:

- Customizing the `xxx-theme` function;
- Customizing the color theme, i.e., `config-colors()`;
- Customizing the header;
- Customizing the footer;
- Customizing the `slide` method;
- Customizing special slide methods, such as `title-slide` and `focus-slide` methods;

To demonstrate how to create a theme with Touying, let's step by step create a simple and aesthetically pleasing Bamboo theme.

## Modifying Existing Themes

If you want to modify a Touying internal theme locally instead of creating one from scratch, you can achieve this by:

1. Copying the [theme code](https://github.com/touying-typ/touying/tree/main/themes) from the `themes` directory to your local, for example, copying `themes/university.typ` to your local `university.typ`.
2. Replacing the `#import "../src/exports.typ": *` command at the top of the `university.typ` file with `#import "@preview/touying:0.7.0": *`.

Then you can import and use the theme by:

```typst
#import "@preview/touying:0.7.0": *
#import "university.typ": *

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact@mail.com],
    logo: emoji.school,
  ),
)
```

## Importing

Depending on whether the theme is your own or part of Touying, you can import it in two ways:

If it's just for your own use, you can directly import Touying:

```typst
#import "@preview/touying:0.7.0": *
```

If you want the theme to be part of Touying, placed in the Touying `themes` directory, then you should change the import statement above to

```typst
#import "../src/exports.typ": *
```

And add

```typst
#import "bamboo.typ"
```

in Touying's `themes/themes.typ`.

## register Function and init Method

Next, we will differentiate between the `bamboo.typ` template file and the `main.typ` file, which is sometimes omitted.

Generally, the first step in making slides is to determine the font size and page aspect ratio, so we need to register an initialization method:

```example
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let bamboo-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
    ),
    ..args,
  )

  body
}

// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(aspect-ratio: "16-9")

= First Section

== First Slide

A slide with a title and an *important* information.
```

As you can see, we've created a `bamboo-theme` function and passed in an `aspect-ratio` parameter to set the page aspect ratio. We've also added `set text(size: 20pt)` to set the font size. You can also place some additional global style settings here, such as `set par(justify: true)`, etc. If you need to use `self`, you might consider using `config-methods(init: (self: none, body) => { .. })` to register an `init` method.

As you can see, later in `main.typ`, we apply our style settings through `#show: bamboo-theme.with(aspect-ratio: "16-9")`, and internally `bamboo` uses `show: touying-slides.with()` for corresponding configurations.

## Color Theme

Picking an aesthetically pleasing color theme for your slides is key to making good slides. Touying provides built-in color theme support to minimize API differences between different themes. Touying offers two dimensions of color selection. The first dimension is `neutral`, `primary`, `secondary`, and `tertiary`, which are used to distinguish color tones, with `primary` being the most commonly used theme color. The second dimension is `default`, `light`, `lighter`, `lightest`, `dark`, `darker`, `darkest`, which are used to distinguish brightness levels.

Since we are creating the Bamboo theme, we have chosen a color close to bamboo for the `primary` theme color, `rgb("#5E8B65")`, and added neutral colors `neutral-lightest`, `neutral-darkest`, respectively, as the background and font colors.

As shown in the following code, we can use the `config-colors()` method to modify the color theme. Its essence is a wrapper for `self.colors += (..)`.

```typst
#let bamboo-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
    ),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    ..args,
  )

  body
}
```

After adding the color theme as shown above, we can access this color through `self.colors.primary`.

It's also worth noting that users can change the color theme at any time in `main.typ` by using `config-colors()` or

```typst
#show: touying-set-config.with(config-colors(
  primary: blue,
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
))
```

This feature of being able to change the color theme at any time is a testament to Touying's powerful customizability.

## Practical: Custom Alert Method

Generally, we need to provide a `#alert[..]` function for users, similar to `#strong[..]`, both of which are used to emphasize the current text. Typically, `#alert[..]` will change the text color to the theme color, which will look more aesthetically pleasing, and this is our next goal.

We add a line in the `register` function:

```typst
config-methods(alert: (self: none, it) => text(fill: self.colors.primary, it))
```

This code means to change the text color to `self.colors.primary`, and the `self` here is passed in through the parameter `self: none`, so that we can get the `primary` theme color in real-time.

We can also use a shorthand.

```typst
config-methods(alert: utils.alert-with-primary-color)
```

## Custom Header and Footer

Here, I assume you have read the page layout section, so we know that we should add a header and footer to the slides.

First, we add `config-store(title: none)`, which means that we save the current slide's title as a member variable `self.store.title` inside `self`, making it convenient for us to use in the header and for subsequent modifications. Similarly, we also create a `config-store(footer: footer)` and save the `footer: none` parameter of the `bamboo-theme` function for display in the footer at the bottom left corner.

Then it's worth noting that our header is actually a content function with `self` as a parameter, like `let header(self) = { .. }`, rather than a simple content, so that we can get the information we need from the latest `self`, such as `self.store.title`. The footer is the same.

The `components.cell` used here is actually `#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)`, and `show: components.cell` is also a shorthand for `components.cell(body)`, and the `show: pad.with(.4em)` for the footer is the same.

Another point to note is that the `utils` module contains many contents and methods related to counters and states, such as `utils.display-current-heading(level: 1)` for displaying the current `section`, and `context utils.slide-counter.display() + " / " + utils.last-slide-number` for displaying the current page number and total number of pages.

We also find that we use syntax like `utils.call-or-display(self, self.store.footer)` to display `self.store.footer`, which is to deal with the situation of `self.store.footer = self => {..}`, so that we can unify the display of content functions and content.

To ensure that the header and footer are displayed correctly and have enough spacing from the main text, we need to set the margin, such as `config-page(margin: (top: 4em, bottom: 1.5em, x: 2em))`.

We also need to customize a `slide` method, which accepts `#let slide(title: auto, ..args) = touying-slide-wrapper(self => {..})`, where `self` in the callback function is a required parameter to get the latest `self`; the second `title` is used to update `self.store.title` for display in the header; the third `..args` is used to collect the remaining parameters and pass them to `touying-slide(self: self, ..args)`, which is also necessary for the normal functioning of Touying's `slide` feature. Moreover, we need to register this method in the `bamboo-theme` function using `config-methods(slide: slide)`.

```example
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    utils.display-current-heading(level: 1)
    linebreak()
    set text(size: 1.5em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )

  body
}


// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(aspect-ratio: "16-9")

= First Section

== First Slide

A slide with a title and an *important* information.
```

## Custom Special Slides

On the basis of the basic slides we've created, we further add some special slide functions, such as `title-slide`, `focus-slide`, and custom `slides` methods.

For the `title-slide` method, first, we can obtain the information saved in `self.info` through `let info = self.info + args.named()`, and we can also update the information with `args.named()` passed in through the function parameters for subsequent use in the form of `info.title`. The specific page content `body` will vary for each theme, so I won't go into too much detail here.

For the `new-section-slide` method, it's the same, but the only thing to note is that we registered `new-section-slide-fn: new-section-slide` in `config-methods()`, so `new-section-slide` will be automatically called when encountering a first-level heading.

```example
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    utils.display-current-heading(level: 1)
    linebreak()
    set text(size: 1.5em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold", info.title),
    )
    set text(fill: self.colors.neutral-darkest)
    if info.author != none {
      block(info.author)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
    if info.contact != none {
      block(info.contact)
    }
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", style: "italic")
    utils.display-current-heading(level: 1)
  }
  touying-slide(self: self, main-body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 2em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )

  body
}


// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact@mail.com],
  ),
)

#title-slide()

= First Section

== First Slide

A slide with a title and an *important* information.

#focus-slide[
  Focus on it!
]
```



## Conclusion

Congratulations! You've created a simple and elegant theme. Perhaps you may find that Touying introduces a wealth of concepts, making it initially challenging to grasp. This is normal, as Touying opts for functionality over simplicity. However, thanks to Touying's comprehensive and unified approach, you can easily extract commonalities between different themes and transfer your knowledge seamlessly. You can also save global variables, modify existing themes, or switch between themes effortlessly, showcasing the benefits of Touying's decoupling.