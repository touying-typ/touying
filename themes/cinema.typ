#import "../src/exports.typ": *

#let basalt-base      = oklch(14%, 0.01, 30deg)      
#let basalt-dark      = oklch(10%, 0.01, 30deg)      
#let basalt-soft      = oklch(20%, 0.01, 30deg)      
#let bone             = oklch(94%, 0.01, 75deg)      
#let bone-grey        = oklch(72%, 0.01, 70deg)      
#let warm-grey        = oklch(60%, 0.01, 55deg)      
#let ash-grey         = oklch(42%, 0.01, 40deg)      
#let citron-bright    = oklch(89%, 0.09, 105deg)     
#let citron-dim       = oklch(76%, 0.07, 105deg)     
#let champagne        = oklch(91%, 0.08, 85deg)      
#let cherry-red       = oklch(65%, 0.22, 15deg)      
#let cherry-soft      = oklch(55%, 0.17, 10deg)      
#let error-red        = oklch(60%, 0.27, 20deg)      
#let mint-silver      = oklch(88%, 0.07, 175deg)     
#let selection-hi     = oklch(40%, 0.06, 270deg)     

#let _basalt-stripes = tiling(
  size: (12pt, 12pt),
  relative: "parent",
  place(
    line(
      start: (0%, 0%),
      end: (100%, 100%),
      stroke: (
        paint: basalt-soft.transparentize(60%),
        thickness: 0.6pt,
      ),
    ),
  ),
)

#let _basalt-crosshatch = tiling(
  size: (12pt, 12pt),
  relative: "parent",
  place(
    line(
      start: (0%, 0%),
      end: (100%, 100%),
      stroke: (
        paint: basalt-soft.transparentize(60%),
        thickness: 0.6pt,
      ),
    ),
  )
  +
  place(
    line(
      start: (0%, 100%),
      end: (100%, 0%),
      stroke: (
        paint: basalt-soft.transparentize(60%),
        thickness: 0.6pt,
      ),
    ),
  ),
)

// Helper: pick noise image from array, cycling
// noise-images: array of image paths (strings)
// index: slide number (0-based)
// title-noise: special noise path for title slide (or none)
#let _pick-noise(noise-images, index, title-noise: none) = {
  if title-noise != none and index == 0 {
    title-noise
  } else if noise-images.len() > 0 {
    let effective = if title-noise != none { index - 1 } else { index }
    noise-images.at(calc.rem(calc.max(effective, 0), noise-images.len()))
  } else {
    none
  }
}

#let _basalt-bg(self, is-title: false, is-focus: false) = {
  let page-width = if self.page.paper == "presentation-16-9" {
    841.89pt
  } else {
    793.7pt
  }
  let page-height = if self.page.paper == "presentation-16-9" {
    473.56pt
  } else {
    595.28pt
  }

  // Layer 1 is the Base gradient. Diagonal.
  if is-title {
    rect(
      width: 100%,
      height: 100%,
      fill: gradient.linear(
        basalt-dark,
        cherry-soft.transparentize(70%),
        basalt-base,
        angle: 135deg,
        space: oklch,
      ),
    )
  } else if is-focus {    
  // No-Op
  } else {
    rect(
      width: 100%,
      height: 100%,
fill: gradient.linear(
  selection-hi,
  basalt-soft,
  cherry-soft.transparentize(35%),
  citron-dim.transparentize(40%),
  warm-grey,
  angle: 160deg,
  space: oklch,
),)
 }

  // Then Radial glow 
  if is-title {
    place(
      center + horizon,
      rect(
        width: 100%,
        height: 100%,
        fill: gradient.radial(
          cherry-red.transparentize(85%),
          basalt-base.transparentize(100%),
          center: (50%, 40%),
          radius: 70%,
          space: oklch,
        ),
      ),
    )
   } else if is-focus {
  // no-op
  } else {
    place(
      center + top,
      rect(
        width: 100%,
        height: 100%,
        fill: gradient.radial(
          selection-hi.transparentize(80%),
          basalt-base.transparentize(100%),
          center: (80%, 0%),
          radius: 60%,
          space: oklch,
        ),
      ),
    )
  }

  if is-title {
  place(
    top + left,
    rect(width: 100%, height: 100%, fill: _basalt-stripes),
  )
  }

  // Then we apply the noise overlay
  let noise-images = self.store.at("noise-images", default: ())
  let title-noise = self.store.at("title-noise", default: none)
  let slide-idx = context {
    utils.slide-counter.get().first() - 1
  }

  // We can't easily get the counter value at theme-build time,
  // so we always place title noise on title slides and cycle for others.
  if is-title and title-noise != none {
    place(
      top + left,
      image(title-noise, width: 100%, height: 100%),
    )
  } else if not is-title and noise-images.len() > 0 {
    // Use a context block to read the current slide number
    context {
      let idx = utils.slide-counter.get().first() - 1
      let path = noise-images.at(
        calc.rem(calc.max(idx, 0), noise-images.len()),
      )
      place(top + left, image(path, width: 100%, height: 100%))
    }
  }

  // Finished what we came for, now exit
  if is-focus {
    return
  }

  // In the other case, layer five is decorative corner accents (conic gradient circles)
  if not is-title {
    // Top-left small conic accent
    place(
      left + top,
      dx: -8pt,
      dy: -8pt,
      circle(
        radius: 18pt,
        fill: gradient.conic(
          cherry-red.transparentize(70%),
          citron-bright.transparentize(85%),
          cherry-red.transparentize(70%),
          space: oklch,
        ),
      ),
    )
    // Bottom-right small conic accent
    place(
      right + bottom,
      dx: 8pt,
      dy: 8pt,
      circle(
        radius: 18pt,
        fill: gradient.conic(
          mint-silver.transparentize(70%),
          selection-hi.transparentize(80%),
          mint-silver.transparentize(70%),
          space: oklch,
        ),
      ),
    )
  }
}

// A nice progress bar
#let _basalt-progress-bar(height: 2pt) = {
  components.progress-bar(
    height: height,
    gradient.linear(cherry-red, citron-bright, mint-silver, space: oklch),
    basalt-soft,
  )
}

/// Default slide.
#let slide(
  title: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }

  let header(self) = {
    set std.align(top)
    block(
      width: 100%,
      height: 3.6em,
      inset: 0pt,
      clip: true,
      {
        // Base 
        place(
          top + left,
          rect(
            width: 100%,
            height: 100%,
            fill: gradient.linear(
              basalt-dark,
              selection-hi.transparentize(40%),
              basalt-dark,
              space: oklch,
            ),
            stroke: none,
          ),
        )

        // Crosshatch
        place(
          top + left,
          rect(
            width: 100%,
            height: 100%,
            fill: _basalt-crosshatch,
            stroke: none,
          ),
        )

        // A subtle accent line
        place(
          bottom + left,
          rect(
            width: 100%,
            height: 1.5pt,
            fill: gradient.linear(
              cherry-red,
              citron-bright.transparentize(50%),
              mint-silver.transparentize(70%),
              space: oklch,
            ),
            stroke: none,
          ),
        )

        // Our header text
        place(
          left + horizon,
          dx: 1.5em,
          text(
            fill: bone,
            weight: "medium",
            size: 1.8em,
            if self.store.title != none {
              utils.call-or-display(self, self.store.title)
            } else {
              utils.display-current-heading(depth: self.slide-level)
            },
          ),
        )
      },
    )
  v(10em)
  }

  let footer(self) = {
    set text(size: 0.7em, fill: ash-grey)
    set std.align(bottom)
    pad(
      .4em,
      components.left-and-right(
        utils.call-or-display(self, self.store.footer),
        text(
          fill: warm-grey,
          utils.call-or-display(self, self.store.footer-right),
        ),
      ),
    )
    if self.store.progress-bar {
      place(bottom, _basalt-progress-bar())
    }
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )

  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})


#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      background: _basalt-bg(self, is-title: true),
      // Remove standard margins so we have full control over placement
      margin: 0em,
    ),
  )
  let info = self.info + args.named()
  
  let body = {
    // We use a full-page rect with padding to control the layout manually
    rect(
      width: 100%, 
      height: 100%, 
      fill: none, 
      inset: (x: 3em, top: 3em, bottom: 3em), 
      {
        //  Title Section (Top-Left)
        align(top + left)[
          #block(below: 1em)[
            #text(
              size: 3.8em,
              weight: "extrabold",
              fill: gradient.linear(bone, citron-bright, space: oklch),
              if info.title != none { info.title } else { "Title" }
            )
          ]
          
          #if info.subtitle != none {
            block(below: 0.8em)[
              #text(
                size: 2.2em,
                weight: "regular",
                fill: champagne.transparentize(20%),
                info.subtitle
              )
            ]
          }

          #if info.at("description", default: none) != none {
            block(below: 0.5em)[
              #text(
                size: 0.9em, 
                weight: "regular", 
                fill: warm-grey,
                info.description
              )
            ]
          }
        ]

        // Footer Section 
        place(bottom + center)[
          #stack(dir: ltr, spacing: 4em,
            if info.date != none {
              text(
                size: 0.7em,
                fill: mint-silver.transparentize(30%),
                utils.display-info-date(self),
              )
            },
            if info.author != none {
               let authors = if type(info.author) == array {
                  info.author
                } else {
                  (info.author,)
                }
              text(
                size: 0.8em,
                fill: bone.transparentize(15%),
                weight: "bold",
                authors.join(", ", last: " & "),
              )
            },
            if info.institution != none {
              text(
                size: 0.7em, 
                fill: ash-grey, 
                info.institution
              )
            }
          )
        ]
      }
    )
  }
  touying-slide(self: self, body)
})


/// New section slide.
#let new-section-slide(config: (:), level: 1, body) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(
      self,
      config-page(
        background: _basalt-bg(self, is-title: false),
        margin: (left: 0%, right: 0%, top: 15%, bottom: 0%),
      ),
    )
    let slide-body = {
      set std.align(center)
      // Large section number with conic gradient fill
      text(
        fill: gradient.conic(
          cherry-red.transparentize(30%),
          citron-bright.transparentize(30%),
          mint-silver.transparentize(30%),
          cherry-red.transparentize(30%),
          space: oklch,
        ),
        size: 4.5em,
        weight: "extrabold",
        utils.display-current-heading-number(level: level),
      )
      v(0.5em)
      // Section title
      text(
        fill: gradient.linear(bone, citron-bright, space: oklch),
        size: 5em,
        utils.display-current-heading(level: level, numbered: false),
      )
      body
    }
    touying-slide(self: self, config: config, slide-body)
  },
)


/// Outline slide.
#let outline-slide(config: (:), leading: 40pt) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(
      self,
      config-common(freeze-slide-counter: true),
      config-page(
        background: _basalt-bg(self, is-title: false),
        margin: 2em,
      ),
    )
    set text(size: 1.2em, fill: bone)
    set par(leading: leading)
    let body = {
      grid(
        columns: (1fr, 1.5fr),
        rows: 1fr,
        std.align(
          center + horizon,
          text(
            size: 2em,
            weight: "bold",
            fill: gradient.linear(
              citron-bright,
              mint-silver,
              space: oklch,
            ),
            [CONTENTS],
          ),
        ),
        std.align(
          left + horizon,
          {
            set text(weight: "bold", fill: bone)
            components.custom-progressive-outline(
              level: none,
              depth: 1,
              numbered: (true,),
            )
          },
        ),
      )
    }
    touying-slide(self: self, config: config, body)
  },
)


/// Focus slide.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      background: _basalt-bg(self, is-title: false),
      fill: gradient.radial(
        cherry-red.transparentize(40%),
        basalt-dark,
        center: (50%, 50%),
        radius: 80%,
        space: oklch,
      ),
      margin: 2em,
    ),
  )
  set text(fill: bone, size: 2em, weight: "bold")
  touying-slide(
    self: self,
    config: config,
    std.align(horizon + center, body),
  )
})


/// Ending slide.
#let ending-slide(config: (:), title: none, body) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(
      self,
      config-common(freeze-slide-counter: true),
      config-page(
        background: _basalt-bg(self, is-title: true),
        margin: 2em,
      ),
    )
    let content = {
      set std.align(center + horizon)
      if title != none {
        block(
          fill: gradient.linear(
            cherry-red,
            cherry-soft,
            space: oklch,
          ),
          inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
          radius: 0.5em,
          text(size: 1.5em, fill: bone, weight: "bold", title),
        )
      }
      v(1em)
      text(fill: warm-grey, body)
    }
    touying-slide(self: self, config: config, content)
  },
)


/// Touying cinema theme.
///
/// Example:
///
/// ```typst
/// #show: basalt-theme.with(
///   aspect-ratio: "16-9",
///   noise-images: (
///     "assets/noise-1.png",
///     "assets/noise-2.png",
///     "assets/noise-3.png",
///   ),
///   title-noise: "assets/noise-title.png",
///   config-info(
///     title: [My Presentation],
///     subtitle: [A basalt-themed talk],
///     author: [Author Name],
///     date: datetime.today(),
///   ),
/// )
///
/// #title-slide()
///
/// = Section One
/// == First Slide
/// Hello, basalt.
/// ```
///
/// - aspect-ratio (string): Default `"16-9"`.
/// - noise-images (array): Array of image paths cycled across slides.
/// - title-noise (string, none): Special noise overlay for the title slide.
/// - footer (content, function): Left footer content.
/// - footer-right (content, function): Right footer content.
/// - progress-bar (boolean): Show gradient progress bar. Default `true`.
#let cinema-theme(
  aspect-ratio: "16-9",
  noise-images: (),
  title-noise: none,
  footer: none,
  footer-right: context utils.slide-counter.display()
    + " / "
    + utils.last-slide-number,
  progress-bar: true,
  ..args,
  body,
) = {
  set text(size: 20pt, fill: bone)
  show heading.where(level: 1): set heading(numbering: "01")
  set par(justify: true)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      numbering: none,
      margin: (top: 5.5em, bottom: 2em, x: 1.5em),
      fill: basalt-base,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        // Heading styles
        show heading: set text(
          fill: gradient.linear(
            citron-bright,
            mint-silver,
            space: oklch,
          ),
        )
        // Strong text in cherry
        show strong: set text(fill: cherry-red)
        // Emphasis in champagne
        show emph: set text(fill: champagne)
        // Code blocks
        show raw.where(block: true): set block(
          fill: basalt-dark,
          inset: 0.8em,
          radius: 4pt,
          stroke: (
            paint: ash-grey.transparentize(60%),
            thickness: 0.5pt,
          ),
        )
        show raw.where(block: true): set text(
          fill: citron-dim,
          size: 0.85em,
        )
        show raw.where(block: false): set text(fill: citron-bright)
        show raw.where(block: false): it => {
          box(
            fill: basalt-soft,
            inset: (x: 3pt, y: 1.5pt),
            radius: 2pt,
            it,
          )
        }
        // Links
        show link: set text(fill: mint-silver)
        show link: it => underline(it)
        // List markers
        set list(
          marker: text(fill: cherry-red, sym.diamond.filled),
        )
        // Tables
        show figure.where(kind: table): set figure.caption(
          position: top,
        )
        show figure.caption: set text(size: 0.7em, fill: warm-grey)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: cherry-red,
      primary-light: cherry-soft,
      primary-dark: basalt-dark,
      secondary: citron-bright,
      tertiary: mint-silver,
      neutral-lightest: bone,
      neutral-light: bone-grey,
      neutral-dark: ash-grey,
      neutral-darkest: basalt-dark,
    ),
    config-store(
      align: horizon,
      title: none,
      footer: footer,
      footer-right: footer-right,
      progress-bar: progress-bar,
      noise-images: noise-images,
      title-noise: title-noise,
      background: self => _basalt-bg(self, is-title: false),
    ),
    ..args,
  )

  body
}
