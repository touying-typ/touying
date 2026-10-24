// Madrid theme for Touying in Typst
// Recreates the LaTeX / Pandoc Beamer "Madrid" theme.

#import "../src/exports.typ": *

/// 3D Beamer-style spherical bullet marker.
///
/// - color (color): The primary color of the sphere.
/// - light-color (color): The highlight color near the top-left light source.
/// - dark-color (color): The shadow color near the bottom-right.
/// - radius (length): The radius of the sphere. Default is `0.18em`.
/// - baseline (length): The baseline offset of the sphere. Default is `-0.05em`.
/// -> content
#let beamer-ball(
  color: rgb("#3333b3"),
  light-color: rgb("#a8b8ff"),
  dark-color: rgb("#1a1a7a"),
  radius: 0.18em,
  baseline: -0.05em,
) = {
  box(
    baseline: baseline,
    circle(
      radius: radius,
      fill: gradient.radial(
        light-color,
        color,
        dark-color,
        center: (35%, 35%),
        radius: 75%,
      ),
      stroke: 0.02em + dark-color,
    ),
  )
}

// Vector symbols avoid platform-dependent Unicode/emoji substitution.
#let _nav-icon(kind, fill, width: 0.7em) = {
  let paths = (
    previous: "<path d='M7 2L3 5L7 8Z' fill='currentColor' stroke='none'/>",
    next: "<path d='M3 2L7 5L3 8Z' fill='currentColor' stroke='none'/>",
    slide: "<rect x='1.5' y='2.5' width='7' height='5'/>",
    frame: "<path d='M3 1.5H9V6M1 3.5H7V8.5H1Z'/>",
    subsection: "<path d='M2 2H8M2 4H8M2 6H8M2 8H8'/>",
    section: "<path d='M2 1H7M3 3H9M2 5H7M3 7H9M2 9H7'/>",
    document: "<path d='M2 1H6L8 3V9H2ZM6 1V3H8M3 5H7M3 7H7'/>",
    back: "<path d='M2 5A3 3 0 1 0 3 2M2 1V5H6'/>",
    forward: "<path d='M8 5A3 3 0 1 1 7 2M8 1V5H4'/>",
    search: "<circle cx='4' cy='4' r='2.6'/><path d='M6 6L9 9'/>",
  )
  image(
    bytes(
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10' color='"
        + fill.to-hex()
        + "' fill='none' stroke='currentColor' stroke-width='.55'>"
        + paths.at(kind)
        + "</svg>",
    ),
    width: width,
    height: 0.5em,
    fit: "contain",
  )
}

/// Beamer-style vector navigation with links to pages, frames and sections.
/// Search and viewer history are decorative: Typst cannot emit those PDF actions.
///
/// - fill (color): Symbol color.
/// -> content
#let navigation-symbols(fill: rgb("#adade0")) = context {
  let current = here().page()
  let last = counter(page).final().first()
  let destination(p) = (page: calc.clamp(p, 1, last), x: 0pt, y: 0pt)
  let control(kind, p, width: 0.7em) = link(destination(p), _nav-icon(
    kind,
    fill,
    width: width,
  ))
  let markers = query(<touying-metadata>)
    .filter(it => (
      it.value.at("kind", default: none) == "touying-new-slide"
    ))
    .map(it => it.location().page())
    .dedup()
  let around(pages) = (
    pages
      .filter(p => p < pages.filter(p => p <= current).at(-1, default: 1))
      .at(-1, default: 1),
    pages.filter(p => p <= current).at(-1, default: 1),
    pages.filter(p => p > current).at(0, default: last),
  )
  let group(icon, pages) = {
    let (previous, start, next) = around(pages)
    box(stack(
      dir: ltr,
      spacing: 0pt,
      control("previous", previous, width: 0.5em),
      control(icon, start),
      control("next", next, width: 0.5em),
    ))
  }
  box(stack(
    dir: ltr,
    spacing: 0.15em,
    box(stack(
      dir: ltr,
      spacing: 0pt,
      control("previous", current - 1, width: 0.5em),
      control("slide", current),
      control("next", current + 1, width: 0.5em),
    )),
    group("frame", markers),
    group(
      "subsection",
      query(heading.where(level: 2)).map(it => it.location().page()).dedup(),
    ),
    group(
      "section",
      query(heading.where(level: 1)).map(it => it.location().page()).dedup(),
    ),
    box(stack(dir: ltr, spacing: 0pt, control("document", 1), control(
      "document",
      last,
    ))),
    // Preserve Beamer's familiar final group without mislabelling page links as history/search.
    box(stack(
      dir: ltr,
      spacing: 0pt,
      _nav-icon("back", fill),
      _nav-icon("search", fill),
      _nav-icon("forward", fill),
    )),
  ))
}

// A layered, font-relative shadow, kept outside the measured content bounds.
#let _shadow(body, enabled: true, radius: 0.3em) = layout(available => context {
  if enabled {
    let size = std.measure(body, width: available.width)
    box(width: size.width, height: size.height, {
      for i in range(1, 5) {
        place(top + left, dx: i * 0.06em, dy: i * 0.06em, rect(
          width: size.width,
          height: size.height,
          radius: radius,
          fill: black.transparentize(88%),
          stroke: none,
        ))
      }
      place(top + left, body)
    })
  } else {
    body
  }
})

// Custom block styling for Madrid (rounded Beamer blocks)
#let _cblock(
  self: none,
  title: none,
  fill: none,
  title-fill: none,
  title-color: white,
  body-fill: none,
  body-color: black,
  radius: 0.35em,
  it,
) = {
  let t-fill = if title-fill != none { title-fill } else {
    self.colors.primary.darken(25%)
  }
  let b-fill = if body-fill != none { body-fill } else {
    self.colors.primary-light
  }

  block(width: 100%, above: 1em, below: 0.4em, pad(x: -0.33em, _shadow(
    enabled: self.store.block-shadow,
    radius: radius,
    if title != none {
      grid(
        columns: 1,
        row-gutter: 0pt,
        block(
          fill: t-fill,
          width: 100%,
          inset: (x: 0.33em, top: 0.3em, bottom: 0.35em),
          radius: (top: radius),
          text(
            ..if self.store.title-font == auto { (:) } else {
              (font: self.store.title-font)
            },
            fill: title-color,
            weight: "regular",
            size: 1.1em,
            title,
          ),
        ),
        rect(width: 100%, height: 0.15em, stroke: none, fill: gradient.linear(
          t-fill,
          b-fill,
          angle: 90deg,
        )),
        block(
          fill: b-fill,
          width: 100%,
          inset: (x: 0.33em, top: 0.2em, bottom: 0.65em),
          radius: (bottom: radius),
          text(fill: body-color, it),
        ),
      )
    } else {
      block(
        fill: b-fill,
        width: 100%,
        inset: (x: 0.33em, y: 0.3em),
        radius: radius,
        text(fill: body-color, it),
      )
    },
  )))
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
    title-fill: self.colors.alert.darken(25%),
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
    title-fill: self.colors.example.darken(25%),
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
        inset: (x: 0.78em, top: 0.25em),
        align(
          left + horizon,
          {
            text(
              ..if self.store.title-font == auto { (:) } else {
                (font: self.store.title-font)
              },
              fill: self.colors.neutral-lightest,
              weight: "regular",
              size: 1.315em,
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

  if self.store.logo != none {
    place(bottom + right, dx: -0.3em, dy: -1.8em, utils.call-or-display(
      self,
      self.store.logo,
    ))
  }

  // Optional navigation symbols above footer on the right.
  if self.store.navigation-symbols {
    place(
      bottom + right,
      dx: -0.3em,
      dy: -1.05em,
      navigation-symbols(fill: self.colors.primary.lighten(60%)),
    )
  }

  set text(
    ..if self.store.small-font == auto { (:) } else {
      (font: self.store.small-font)
    },
    size: 0.55em,
  )
  block(
    width: 100%,
    height: 1.45em,
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
        inset: (x: 0.9em),
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
        align(right + horizon, {
          text(
            fill: self.colors.neutral-lightest,
            utils.call-or-display(self, self.store.footer-date),
          )
          h(2.4em)
          text(
            fill: self.colors.neutral-lightest,
            context utils.slide-counter.display()
              + " / "
              + utils.last-slide-number,
          )
        }),
      ),
    ),
  )
}

/// Slide function
#let _madrid-align(alignment, body) = {
  // Beamer's centered frames have more stretch below the content than above.
  if alignment in (horizon + left, horizon + center, horizon + right, horizon) {
    let horizontal = if alignment == horizon + center { center } else if (
      alignment == horizon + right
    ) { right } else { left }
    block(width: 100%, height: 100%, {
      v(1fr)
      std.align(horizontal, body)
      v(1.5fr)
    })
  } else {
    std.align(alignment, body)
  }
}

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
  if self.store.title == none {
    self = utils.merge-dicts(self, config-page(margin: (top: 0.85em)))
  }
  let new-setting = body => {
    show: _madrid-align.with(self.store.align)
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

/// Title slide for Madrid theme.
///
/// - numbered (bool): Whether this frame is counted. Default is `true`.
/// - extra (content, none): Additional title-page content.
/// - config (dictionary): Per-slide configuration, applied after defaults.
#let title-slide(
  config: (:),
  extra: none,
  numbered: true,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: not numbered),
    config-page(margin: (top: 2.06em, bottom: 3.5em, x: 0.67em)),
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
    set std.align(center + horizon)
    set super(size: 0.73em)

    // Rounded blue box with title
    _shadow(enabled: self.store.title-shadow, block(
      fill: self.colors.primary,
      inset: (x: 0.7em, top: 0.95em, bottom: 0.95em),
      radius: 0.35em,
      width: 100%,
      breakable: false,
      align(center, {
        text(
          ..if self.store.title-font == auto { (:) } else {
            (font: self.store.title-font)
          },
          size: 1.315em,
          fill: self.colors.neutral-lightest,
          weight: "regular",
          info.title,
        )
        if info.subtitle != none {
          linebreak()
          v(0.3em)
          text(size: 1em, fill: self.colors.neutral-lightest, info.subtitle)
        }
      }),
    ))

    v(1.8em)

    // Author(s)
    if info.authors.len() > 0 {
      grid(
        columns: (1fr,) * calc.min(info.authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 0.4em,
        ..info.authors.map(author => text(
          size: 1.0em,
          fill: self.colors.neutral-darkest,
          author,
        ))
      )
    }

    // Institution
    if info.institution != none {
      v(0.55em)
      text(
        ..if self.store.small-font == auto { (:) } else {
          (font: self.store.small-font)
        },
        size: 0.73em,
        fill: self.colors.neutral-darkest,
        {
          set par(leading: 0.5em, spacing: 1.5em)
          info.institution
        },
      )
    }

    // Date
    if info.date != none {
      v(0.61em)
      text(
        size: 1em,
        fill: self.colors.neutral-darkest,
        if type(info.date) == datetime {
          info.date.display(self.at("datetime-format", default: auto))
        } else {
          info.date
        },
      )
    }

    if extra != none {
      v(0.6em)
      text(size: 0.8em, extra)
    }
  }

  touying-slide(self: self, body)
})

// One renderer keeps normal and progressive outlines identical in geometry.
#let _madrid-outline(
  self,
  progressive: false,
  level: 1,
  numbered: true,
  alpha: 80%,
  ..args,
) = context {
  let current = utils.current-heading(level: level)
  let sections = query(heading.where(level: level))
  let current-index = sections.position(it => (
    current != none and it.location() == current.location()
  ))
  let next-page = if current-index != none {
    sections.at(current-index + 1, default: none)
  } else { none }
  show outline.entry: it => {
    let faded = (
      progressive
        and (
          current == none
            or it.element.location().page() < current.location().page()
            or (
              next-page != none
                and it.element.location().page() >= next-page.location().page()
            )
        )
    )
    let color = if faded { self.colors.primary.lighten(alpha) } else {
      self.colors.primary
    }
    let shade(c) = if faded { c.lighten(alpha) } else { c }
    let marker = if it.level == 1 and numbered {
      circle(
        radius: 0.55em,
        stroke: none,
        fill: gradient.radial(
          shade(self.colors.primary.lighten(65%)),
          color,
          shade(self.colors.primary.darken(35%)),
          center: (30%, 25%),
          radius: 80%,
        ),
        inset: 0pt,
        align(center + horizon, text(fill: white, size: 0.73em, str(
          query(heading.where(level: 1)).position(h => (
            h.location() == it.element.location()
          ))
            + 1,
        ))),
      )
    } else {
      beamer-ball(
        color: color,
        light-color: color.lighten(65%),
        dark-color: color.darken(35%),
      )
    }
    block(
      above: 0pt,
      below: if it.level == 1 { 3.6em } else { 0.5em },
      pad(left: (it.level - 1) * 1.5em, link(it.element.location(), grid(
        columns: (1.54em, 1fr),
        column-gutter: 0pt,
        align: horizon,
        marker, text(fill: color, utils.short-heading(self: self, it.element)),
      ))),
    )
  }
  pad(left: -0.33em, outline(title: none, ..args))
}

/// Section slide with a progressive outline. The current section is highlighted.
///
/// - config (dictionary): Per-slide configuration.
/// - level (int): Heading level used to identify the current section.
/// - numbered (bool): Whether to show section numbers when headings are numbered.
/// - alpha (ratio): Fade of other sections. Default is `80%`.
/// - title (content, function): Outline slide title. Default is the theme's section-outline-title.
/// - body (content): Additional content for the section slide.
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  alpha: 80%,
  title: auto,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(margin: (bottom: 3.2em)), config)
  self.store.title = if title == auto {
    self.store.section-outline-title
  } else { title }
  let setting(body) = {
    set align(left + horizon)
    _madrid-outline(
      self,
      progressive: true,
      level: level,
      numbered: numbered,
      alpha: alpha,
      depth: level,
    )
    body
  }
  touying-slide(self: self, config: config, setting: setting, body)
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

/// Outline slide for Madrid theme.
///
/// - numbered (bool): Whether section spheres contain numbers. Default is `true`.
/// - depth (int): Maximum heading depth. Default is `1` (sections only).
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  numbered: true,
  depth: 1,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(margin: (bottom: 3.2em)), config)
  self.store.title = title
  touying-slide(
    self: self,
    setting: body => std.align(left + horizon, body),
    _madrid-outline(self, numbered: numbered, depth: depth, ..args),
  )
})

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
/// - align (alignment): The default alignment of slide content. Default is `horizon + left`.
/// - title (content, function): The title displayed in the header banner. Default is current heading.
/// - subtitle (content, function, none): Optional subtitle displayed below the title in the header banner.
/// - header (content, function, auto): Custom slide header override. Default is `auto`.
/// - footer (content, function, auto): Custom slide footer override. Default is `auto`.
/// - header-height (length): Height of the top header banner. Default is `2.5em`.
/// - navigation-symbols (bool): Whether to display Beamer navigation symbols. Default is `true`.
/// - logo (content, function, none): Bottom-right logo. Default reads `info.logo`.
/// - block-shadow (bool): Whether rounded blocks cast shadows. Default is `true`.
/// - title-shadow (bool): Whether the title panel casts a shadow. Default is `true`.
/// - section-outline-title (content, function): Title for progressive outline slides.
/// - font-size (length): Base font size. Default is `24pt`.
/// - sans-math (bool): Use Beamer-style sans-serif math letters. Default is `true`.
/// - footer-left (content, function): Content displayed in the left footer cell. Default is author.
/// - footer-right (content, function): Content displayed in the center footer cell. Default is title.
/// - footer-date (content, function): Content displayed in the date part of the right footer cell. Default is date.
/// - primary (color): Primary theme color. Default is `rgb("#3333b3")`.
/// - primary-light (color, auto): Block body color. Default derives from the primary color.
/// - alert (color): Inline alert and alert block color. Default is `rgb("#ff0000")`.
/// - alert-light (color, auto): Alert block body color. Default derives from the alert color.
/// - example (color): Accent color for example blocks. Default is `rgb("#008000")`.
/// - example-light (color, auto): Example block body color. Default derives from the example color.
/// - font (auto, str, array): Font family for text. Default is `auto`.
/// - title-font (auto, str, array): Font for frame, title-panel and block headings. Default inherits the body font.
/// - small-font (auto, str, array): Font for footer and institution text. Default inherits the body font.
#let madrid-theme(
  aspect-ratio: "16-9",
  align: horizon + left,
  title: self => utils.display-current-heading(depth: self.slide-level),
  subtitle: none,
  header: auto,
  footer: auto,
  header-height: 2.5em,
  navigation-symbols: true,
  logo: self => self.info.logo,
  block-shadow: true,
  title-shadow: true,
  section-outline-title: utils.i18n-outline-title,
  font-size: 24pt,
  sans-math: true,
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
  footer-date: self => {
    let short-date = self.info.at("short-date", default: auto)
    if short-date != auto and short-date != none {
      short-date
    } else if self.info.at("date", default: none) != none {
      utils.display-info-date(self)
    } else {
      none
    }
  },
  primary: rgb("#3333b3"),
  primary-light: auto,
  alert: rgb("#ff0000"),
  alert-light: auto,
  example: rgb("#008000"),
  example-light: auto,
  font: auto,
  title-font: auto,
  small-font: auto,
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
      margin: (top: 3.2em, bottom: 1.8em, x: 1em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      notes-fn: notes,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          ..if font == auto { (:) } else { (font: font) },
          size: font-size,
          fill: self.colors.neutral-darkest,
        )
        set par(justify: false, leading: 0.54em, spacing: 0.54em)
        set list(
          marker: beamer-ball(
            color: self.colors.primary,
            light-color: self.colors.primary.lighten(70%),
            dark-color: self.colors.primary.darken(30%),
          ),
          indent: 1em,
          body-indent: 0.64em,
          spacing: 0.8em,
        )
        set enum(spacing: 0.25em)
        show math.equation: it => if sans-math { math.sans(it) } else { it }
        show math.equation.where(block: true): set block(
          above: 1em,
          below: 1.5em,
        )
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: (self: none, body) => text(fill: self.colors.alert, body),
      tblock: _cblock,
    ),
    config-colors(
      primary: primary,
      primary-light: if primary-light == auto {
        primary.darken(25%).lighten(90%)
      } else { primary-light },
      alert: alert,
      alert-light: if alert-light == auto {
        alert.darken(25%).lighten(90%)
      } else { alert-light },
      example: example,
      example-light: if example-light == auto {
        example.darken(25%).lighten(90%)
      } else { example-light },
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
      logo: logo,
      block-shadow: block-shadow,
      title-shadow: title-shadow,
      section-outline-title: section-outline-title,
      title-font: title-font,
      small-font: small-font,
      footer-left: footer-left,
      footer-right: footer-right,
      footer-date: footer-date,
    ),
    ..args,
  )

  body
}
