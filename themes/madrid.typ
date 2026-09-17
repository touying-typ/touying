// Madrid theme for Touying in Typst
// Recreates the LaTeX / Pandoc Beamer "Madrid" theme.

#import "../src/exports.typ": *

/// 3D Beamer-style spherical bullet marker.
///
/// - color (color): The primary color of the sphere.
/// - light-color (color): The highlight color near the top-left light source.
/// - dark-color (color): The shadow color near the bottom-right.
/// -> content
#let beamer-ball(
  color: rgb("#3333b3"),
  light-color: rgb("#a8b8ff"),
  dark-color: rgb("#1a1a7a"),
) = {
  box(
    baseline: 10%,
    circle(
      radius: 3.2pt,
      fill: gradient.radial(
        light-color,
        color,
        dark-color,
        center: (35%, 35%),
        radius: 75%,
      ),
      stroke: 0.25pt + dark-color,
    ),
  )
}

/// Decorative navigation symbols helper recreating the LaTeX Beamer navigation bar.
///
/// - fill (color): Fill color for the decorative navigation symbols.
/// -> content
#let navigation-symbols(fill: rgb("#9292d6").transparentize(40%)) = {
  set text(size: 6.5pt, fill: fill)
  box(
    inset: (right: 1.2em, bottom: 0.25em),
    [
      #box(baseline: 0%, [◂]) #box(baseline: 0%, [▫]) #box(baseline: 0%, [▸])
      #h(0.3em)
      #box(baseline: 0%, [◂]) #box(baseline: 0%, [▤]) #box(baseline: 0%, [▸])
      #h(0.3em)
      #box(baseline: 0%, [◂]) #box(baseline: 0%, [§]) #box(baseline: 0%, [▸])
      #h(0.3em)
      #box(baseline: 0%, [◂]) #box(baseline: 0%, [▨]) #box(baseline: 0%, [▸])
      #h(0.3em)
      #box(baseline: 0%, [↺]) #box(baseline: 0%, [↻])
    ],
  )
}

// Custom block styling for Madrid (rounded Beamer blocks)
#let _cblock(
  self: none,
  title: none,
  fill: none,
  title-fill: none,
  title-color: white,
  body-fill: none,
  body-color: black,
  radius: 4pt,
  it,
) = {
  let t-fill = if title-fill != none { title-fill } else { self.colors.primary }
  let b-fill = if body-fill != none { body-fill } else {
    self.colors.primary-light
  }

  if title != none {
    grid(
      columns: 1,
      row-gutter: 0pt,
      block(
        fill: t-fill,
        width: 100%,
        inset: (x: 0.8em, top: 0.45em, bottom: 0.45em),
        radius: (top: radius),
        text(fill: title-color, weight: "bold", size: 0.95em, title),
      ),
      block(
        fill: b-fill,
        width: 100%,
        inset: (x: 0.8em, top: 0.55em, bottom: 0.55em),
        radius: (bottom: radius),
        text(fill: body-color, it),
      ),
    )
  } else {
    block(
      fill: b-fill,
      width: 100%,
      inset: (x: 0.8em, top: 0.55em, bottom: 0.55em),
      radius: radius,
      text(fill: body-color, it),
    )
  }
}

/// Standard rounded block for Madrid theme.
///
/// - title (content, none): The title of the block.
/// - it (content): The content of the block.
/// -> content
#let cblock(title: none, it) = touying-fn-wrapper-raw(
  _cblock.with(title: title),
  it,
)

/// Alias for `#cblock` to match standard Touying theorem block interface.
///
/// - title (content, none): The title of the block.
/// - it (content): The content of the block.
/// -> content
#let tblock = cblock

/// Alert rounded block for Madrid theme with red header styling.
///
/// - title (content, none): The title of the alert block.
/// - it (content): The content of the alert block.
/// -> content
#let alert-block(title: none, it) = touying-fn-wrapper-raw(
  (self: none, it) => _cblock(
    self: self,
    title: title,
    title-fill: self.colors.alert,
    title-color: white,
    body-fill: self.colors.alert-light,
    it,
  ),
  it,
)

/// Example rounded block for Madrid theme with green header styling.
///
/// - title (content, none): The title of the example block.
/// - it (content): The content of the example block.
/// -> content
#let example-block(title: none, it) = touying-fn-wrapper-raw(
  (self: none, it) => _cblock(
    self: self,
    title: title,
    title-fill: self.colors.example,
    title-color: white,
    body-fill: self.colors.example-light,
    it,
  ),
  it,
)

// Header definition
#let madrid-header(self) = {
  if self.store.header != auto {
    return utils.call-or-display(self, self.store.header)
  }
  if self.store.title != none {
    place(
      top + left,
      block(
        width: 100%,
        height: self.store.header-height,
        fill: self.colors.primary,
        inset: (x: 1.2em),
        align(
          left + horizon,
          {
            text(
              fill: self.colors.neutral-lightest,
              weight: "medium",
              size: 1.2em,
              utils.call-or-display(self, self.store.title),
            )
            if self.store.subtitle != none {
              v(0.2em)
              text(
                fill: self.colors.neutral-lightest.transparentize(20%),
                size: 0.8em,
                utils.call-or-display(self, self.store.subtitle),
              )
            }
          },
        ),
      ),
    )
  }
}

// Footer definition
#let madrid-footer(self) = {
  if self.store.footer != auto {
    return utils.call-or-display(self, self.store.footer)
  }
  set align(bottom)

  // Optional navigation symbols above footer on the right
  if self.store.navigation-symbols {
    place(
      bottom + right,
      dy: -1.7em,
      navigation-symbols(),
    )
  }

  set text(size: 0.5em)
  block(
    width: 100%,
    height: 1.6em,
    inset: 0pt,
    outset: 0pt,
    stroke: none,
    spacing: 0pt,
    grid(
      columns: (1fr, 1fr, 1fr),
      rows: 100%,
      gutter: 0pt,
      // Madrid uses three equal footer cells: author, title, and date.
      rect(
        width: 100%,
        height: 100%,
        fill: self.colors.primary.darken(50%),
        inset: (x: 0.8em),
        stroke: none,
        align(
          center + horizon,
          text(
            fill: self.colors.neutral-lightest,
            utils.call-or-display(self, self.store.footer-left),
          ),
        ),
      ),
      // Centre footer cell: presentation title.
      rect(
        width: 100%,
        height: 100%,
        fill: self.colors.primary.darken(25%),
        inset: (x: 1.2em),
        stroke: none,
        align(
          center + horizon,
          text(
            fill: self.colors.neutral-lightest,
            utils.call-or-display(self, self.store.footer-right),
          ),
        ),
      ),
      // Right footer cell: date and slide counter.
      rect(
        width: 100%,
        height: 100%,
        fill: self.colors.primary,
        inset: (x: 0.8em),
        stroke: none,
        grid(
          columns: (1fr, auto),
          align: (center + horizon, right + horizon),
          text(
            fill: self.colors.neutral-lightest,
            utils.call-or-display(self, self.store.footer-date),
          ),
          text(
            fill: self.colors.neutral-lightest,
            context utils.slide-counter.display()
              + " / "
              + utils.last-slide-number,
          ),
        ),
      ),
    ),
  )
}

/// Slide function
#let slide(
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  if title != auto {
    self.store.title = title
  }
  if subtitle != auto {
    self.store.subtitle = subtitle
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

/// Title slide for Madrid theme
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config,
  )
  self.store.title = none
  self.info = self.info + args.named()
  let info = self.info
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else if "author" in info {
      info.author
    } else {
      none
    }
    if authors == none {
      ()
    } else if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }

  let body = {
    set std.align(center)

    // Madrid's title material sits in the upper half of the page.
    v(0.65em)

    // Rounded blue box with title
    block(
      fill: self.colors.primary,
      inset: (x: 2em, y: 1.35em),
      radius: 4.5pt,
      width: 100%,
      breakable: false,
      {
        text(
          size: 1.45em,
          fill: self.colors.neutral-lightest,
          weight: "medium",
          info.title,
        )
        if info.subtitle != none {
          v(0.35em)
          text(size: 0.95em, fill: self.colors.neutral-lightest, info.subtitle)
        }
      },
    )

    v(1.0em)

    // Author(s)
    if info.authors.len() > 0 {
      grid(
        columns: (1fr,) * calc.min(info.authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 0.5em,
        ..info.authors.map(author => text(
          size: 1.05em,
          fill: self.colors.neutral-darkest,
          author,
        ))
      )
    }

    // Institution
    if info.institution != none {
      v(2.5em)
      text(size: 0.9em, fill: self.colors.neutral-darkest, info.institution)
    }

    // Date
    if info.date != none {
      v(1.0em)
      text(
        size: 0.95em,
        fill: self.colors.neutral-darkest,
        if type(info.date) == datetime {
          info.date.display(self.at("datetime-format", default: auto))
        } else {
          info.date
        },
      )
    }

    if extra != none {
      v(1em)
      text(size: 0.85em, extra)
    }
  }

  touying-slide(self: self, body)
})

/// Section divider / Outline slide
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  self.store.title = utils.display-current-heading(
    level: level,
    numbered: false,
  )
  let content = {
    set std.align(center + horizon)
    text(
      size: 1.3em,
      fill: self.colors.neutral-darkest,
      utils.display-current-heading(level: level, numbered: numbered),
    )
    body
  }
  touying-slide(self: self, config: config, content)
})

/// Focus slide
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    setting: it => std.align(
      align,
      text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em, it),
    ),
    body,
  )
})

/// Outline slide for Madrid theme
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
) = slide(
  title: title,
  config: config,
  outline(title: none, indent: 1em, ..args),
)

/// Speaker-note panel for this theme. Only styling; `touying-notes` does the layout.
#let notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 32pt, y: 16pt, text(
    fill: self.colors.neutral-lightest,
    utils.display-current-heading(depth: self.slide-level),
  )),
  header-fill: self.colors.primary,
  fill: self.colors.neutral-lightest,
  ..args,
)

/// Main Madrid theme definition recreating the classic LaTeX Beamer Madrid theme.
///
/// - aspect-ratio (str): The aspect ratio of the slides. Default is `"16-9"`.
/// - align (alignment): The default alignment of slide content. Default is `top + left`.
/// - title (content, function): The title displayed in the header banner. Default is current heading.
/// - subtitle (content, function, none): Optional subtitle displayed below the title in the header banner.
/// - header (content, function, auto): Custom slide header override. Default is `auto`.
/// - footer (content, function, auto): Custom slide footer override. Default is `auto`.
/// - header-height (length): Height of the top header banner. Default is `2.2em`.
/// - navigation-symbols (bool): Whether to display decorative Beamer navigation symbols. Default is `false`.
/// - footer-left (content, function): Content displayed in the left footer cell. Default is author.
/// - footer-right (content, function): Content displayed in the center footer cell. Default is title.
/// - footer-date (content, function): Content displayed in the date part of the right footer cell. Default is date.
/// - primary (color): Primary theme color. Default is `rgb("#3333b3")`.
/// - primary-light (color): Light primary color for block bodies. Default is `rgb("#e8ebfa")`.
/// - alert (color): Accent color for alert blocks. Default is `rgb("#cc0000")`.
/// - alert-light (color): Light alert color for alert block bodies. Default is `rgb("#fae8e8")`.
/// - example (color): Accent color for example blocks. Default is `rgb("#008000")`.
/// - example-light (color): Light example color for example block bodies. Default is `rgb("#e8fae8")`.
/// - font (auto, str, array): Font family for text. Default is `auto`.
#let madrid-theme(
  aspect-ratio: "16-9",
  align: top + left,
  title: self => utils.display-current-heading(depth: self.slide-level),
  subtitle: none,
  header: auto,
  footer: auto,
  header-height: 2.2em,
  navigation-symbols: false,
  footer-left: self => {
    let short-author = self.info.at("short-author", default: auto)
    if short-author != auto and short-author != none {
      short-author
    } else {
      self.info.at("author", default: none)
    }
  },
  footer-right: self => {
    let short-title = self.info.at("short-title", default: auto)
    if short-title != auto and short-title != none {
      short-title
    } else {
      self.info.at("title", default: none)
    }
  },
  footer-date: self => if self.info.at("date", default: none) != none {
    utils.display-info-date(self)
  } else {
    none
  },
  primary: rgb("#3333b3"),
  primary-light: rgb("#e8ebfa"),
  alert: rgb("#cc0000"),
  alert-light: rgb("#fae8e8"),
  example: rgb("#008000"),
  example-light: rgb("#e8fae8"),
  font: auto,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      fill: rgb("#ffffff"),
      header: madrid-header,
      footer: madrid-footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 5.2em, bottom: 2.2em, x: 1.2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      notes-fn: notes,
    ),
    config-methods(
      init: (self: none, body) => {
        if font != auto {
          set text(font: font)
        }
        set text(
          size: 20pt,
          fill: self.colors.neutral-darkest,
        )
        set par(justify: false, leading: 0.65em)
        set list(
          marker: beamer-ball(
            color: self.colors.primary,
            light-color: self.colors.primary.lighten(70%),
            dark-color: self.colors.primary.darken(30%),
          ),
          body-indent: 0.5em,
          spacing: 1em,
        )
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color,
      tblock: _cblock,
    ),
    config-colors(
      primary: primary,
      primary-light: primary-light,
      alert: alert,
      alert-light: alert-light,
      example: example,
      example-light: example-light,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      align: align,
      title: title,
      subtitle: subtitle,
      header: header,
      footer: footer,
      header-height: header-height,
      navigation-symbols: navigation-symbols,
      footer-left: footer-left,
      footer-right: footer-right,
      footer-date: footer-date,
    ),
    ..args,
  )

  body
}
