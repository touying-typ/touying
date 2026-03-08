#import "utils.typ"

#let cell = block.with(
  width: 100%,
  height: 100%,
  above: 0pt,
  below: 0pt,
  outset: 0pt,
  breakable: false,
)


/// SIDE BY SIDE
///
/// A simple wrapper around `grid` that creates a grid with a single row.
/// It is useful for creating side-by-side slide.
///
/// It is also the default function for composer in the slide function.
///
/// Example: `side-by-side[a][b][c]` will display `a`, `b`, and `c` side by side.
///
/// - columns (auto): The number of columns. Default is `auto`, which means the number of columns is equal to the number of bodies.
///
/// - gutter (length): The space between columns. Default is `1em`.
///
/// - bodies (content): The contents to display side by side.
///
/// -> content
#let side-by-side(columns: auto, gutter: 1em, ..bodies) = {
  let args = bodies.named()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, ..args, ..bodies)
}


/// Adaptive columns layout
///
/// Example: `components.adaptive-columns(outline())`
///
/// - gutter (length): The space between columns.
///
/// - max-count (int): The maximum number of columns.
///
/// - start (content): The content to place before the columns.
///
/// - end (content): The content to place after the columns.
///
/// - body (content): The content to place in the columns.
///
/// -> content
#let adaptive-columns(
  gutter: 4%,
  max-count: 3,
  start: none,
  end: none,
  body,
) = layout(size => {
  let n = calc.min(
    calc.ceil(
      measure(body).height
        / (size.height - measure(start).height - measure(end).height),
    ),
    max-count,
  )
  if n < 1 {
    n = 1
  }
  start
  if n == 1 {
    body
  } else {
    columns(n, body)
  }
  end
})


/// Touying progress bar.
///
/// - primary (color): The color of the progress bar.
///
/// - secondary (color): The color of the background of the progress bar.
///
/// - height (length): The height of the progress bar, optional. Default is `2pt`.
///
/// -> content
#let progress-bar(height: 2pt, primary, secondary) = utils.touying-progress(
  ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      rows: height,
      gutter: 0pt,
      cell(fill: primary), cell(fill: secondary),
    )
  },
)


/// Left and right.
///
/// - left (content): The content of the left part.
///
/// - right (content): The content of the right part.
///
/// -> content
#let left-and-right(left, right) = grid(
  columns: (auto, 1fr, auto),
  left, none, right,
)


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#checkerboard[...][...]` stacks horizontally and `#checkerboard(columns: 1)[...][...]` stacks vertically.
///
/// - alignment (alignment): The alignment applied to the contents of each checkerboard cell. Default is `center + horizon`.
///
/// - primary (color): The background color of odd cells. Default is `white`.
///
/// - secondary (color): The background color of even cells. Default is `silver`.
///
/// -> content
#let checkerboard(
  columns: none,
  rows: none,
  alignment: center + horizon,
  primary: white,
  secondary: silver,
  ..bodies,
) = {
  let bodies = bodies.pos()
  let columns = if type(columns) == int {
    (1fr,) * columns
  } else if columns == none {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  let num-cols = columns.len()
  let rows = if type(rows) == int {
    (1fr,) * rows
  } else if rows == none {
    let quotient = calc.quo(bodies.len(), num-cols)
    let correction = if calc.rem(bodies.len(), num-cols) == 0 {
      0
    } else {
      1
    }
    (1fr,) * (quotient + correction)
  } else {
    rows
  }
  let num-rows = rows.len()
  if num-rows * num-cols < bodies.len() {
    panic(
      "number of rows ("
        + str(num-rows)
        + ") * number of columns ("
        + str(num-cols)
        + ") must at least be number of content arguments ("
        + str(
          bodies.len(),
        )
        + ")",
    )
  }
  let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
  let color-body(idx-body) = {
    let (idx, body) = idx-body
    let (row, col) = cart-idx(idx)
    let color = if calc.even(row + col) {
      primary
    } else {
      secondary
    }
    set align(alignment)
    rect(inset: .5em, width: 100%, height: 100%, fill: color, body)
  }
  let body = grid(
    columns: columns, rows: rows,
    gutter: 0pt,
    ..bodies.enumerate().map(color-body)
  )
  body
}


/// Show progressive outline. It will make other sections except the current section to be semi-transparent.
///
/// Example:
///
/// ```typst
/// #components.progressive-outline()
/// ```
///
/// - alpha (ratio): The transparency of the other sections. Default is `60%`.
///
/// - level (int, auto, none): The heading level used to determine the current section. Use `1` for top-level sections, `auto` for the most recent heading of any level (single-page range), or `none` to disable section detection (show all entries with equal styling). Default is `1`.
///
/// - filter (function, none): An optional function used to hide specific outline entries entirely (rather than just covering them with transparency). The function receives named arguments `cover` (bool), `level` (the level passed to `progressive-outline`), and a positional `outline.entry` argument, and should return `true` to show the entry or `false` to hide it. Default is `none`.
///
/// - transform (function): The transformation applied to each outline entry. It receives named arguments `cover` (bool), `level`, `alpha`, any extra `..args`, and a positional `outline.entry`. Default makes covered entries semi-transparent.
///
/// - args (content): Additional arguments forwarded to `outline()`.
///
/// -> content
#let progressive-outline(
  alpha: 60%,
  level: 1,
  filter: none,
  transform: (cover: false, alpha: 60%, ..args, it) => if cover {
    text(utils.update-alpha(text.fill, alpha), it)
  } else {
    it
  },
  ..args,
) = (
  context {
    // start page and end page
    let start-page = 1
    let end-page = calc.inf
    if level != none {
      let current-heading = utils.current-heading(level: level)
      if current-heading != none {
        start-page = current-heading.location().page()
        if level != auto {
          let next-headings = query(
            selector(heading.where(level: level)).after(
              inclusive: false,
              current-heading.location(),
            ),
          )
          if next-headings != () {
            end-page = next-headings.at(0).location().page()
          }
        } else {
          end-page = start-page + 1
        }
      }
    }
    show outline.entry: it => {
      let is-covered = (
        it.element.location().page() < start-page
          or it.element.location().page() >= end-page
      )
      if filter != none and not filter(cover: is-covered, level: level, it) {
        return none
      }
      transform(
        cover: is-covered,
        level: level,
        alpha: alpha,
        ..args,
        it,
      )
    }

    outline(..args)
  }
)


/// Custom progressive outline function.
///
/// Example:
///
/// ```typst
/// // Basic usage — highlights the current section
/// #components.custom-progressive-outline()
///
/// // Beamer-style: hide subsections of other sections and emphasize the
/// // current subsection within the current section
/// #components.custom-progressive-outline(hide-other-sections-subsections: true)
/// ```
///
/// - self (none): The self context.
///
/// - alpha (ratio): The transparency of the other headings. Default is `60%`.
///
/// - level (auto, int, none): The heading level used to determine the current section. When `hide-other-sections-subsections` is `true` and `level` is `auto`, it automatically defaults to `1` for section-based detection. Default is `auto`.
///
/// - numbered (array): Indicates whether the headings should be numbered. Default is `(false,)`.
///
/// - filled (array): Indicates whether the headings should be filled. Default is `(false,)`.
///
/// - paged (array): Indicates whether the headings should be paged. Default is `(false,)`.
///
/// - numbering (array): An array of numbering strings for the headings. Default is `()`.
///
/// - text-fill (array, none): An array of colors for the text fill of the headings. Default is `none`.
///
/// - text-size (array, none): An array of sizes for the text of the headings. Default is `none`.
///
/// - text-weight (array, none): An array of weights for the text of the headings. Default is `none`.
///
/// - vspace (array, none): An array of vertical spaces above the headings. Default is `none`.
///
/// - title (string, none): The title of the outline. Default is `none`.
///
/// - indent (array): An array of indentations for the headings. Default is `(0em,)`.
///
/// - fill (array): An array of fills for the headings. Default is `(repeat[.],)`.
///
/// - short-heading (boolean): Indicates whether the headings should be shortened. Default is `true`.
///
/// - uncover-fn (function): A function that takes the body of the heading and returns the body of the heading when it is uncovered. Default is the identity function.
///
/// - hide-other-sections-subsections (boolean): When `true`, enables Beamer-style `hideothersubsections` behavior:
///   - Subsections (headings deeper than `level`) belonging to sections other than the current one are hidden entirely.
///   - Within the current section, the active subsection (the most recent one at or before the current page) is highlighted normally.
///   - Other subsections of the current section are shown with `alpha` transparency.
///   - Section-level entries (at `level`) always remain visible, covered with `alpha` when not active.
///   Default is `false`.
///
/// - args (content): The other arguments passed to the `progressive-outline` and `transform`.
///
/// -> content
#let custom-progressive-outline(
  self: none,
  alpha: 60%,
  level: auto,
  numbered: (false,),
  filled: (false,),
  paged: (false,),
  numbering: (),
  text-fill: none,
  text-size: none,
  text-weight: none,
  vspace: none,
  title: none,
  indent: (0em,),
  fill: (repeat[.],),
  short-heading: true,
  uncover-fn: body => body,
  hide-other-sections-subsections: false,
  ..args,
) = {
  // When hide-other-sections-subsections is enabled and no explicit level was
  // given, use level 1 for section-range detection.
  let effective-level = if hide-other-sections-subsections and level == auto {
    1
  } else {
    level
  }

  // Filter that hides subsection entries belonging to non-current sections.
  // A subsection entry has level > effective-level and cover == true.
  let entry-filter = if hide-other-sections-subsections {
    (cover: false, ..filter-args, it) => {
      not (cover and it.level > effective-level)
    }
  } else {
    none
  }

  progressive-outline(
    alpha: alpha,
    level: effective-level,
    filter: entry-filter,
    transform: (cover: false, alpha: alpha, ..transform-args, it) => {
      let array-at(arr, idx) = arr.at(idx, default: arr.last())

      // Helper that builds the styled heading content for a given coverage state.
      // effective-cover == true  → render with alpha (inactive)
      // effective-cover == false → render at full colour (active), wrapped by uncover-fn
      let build-styled-body(effective-cover) = {
        let set-text(level, body) = {
          set text(fill: {
            let text-color = if type(text-fill) == array and text-fill.len() > 0 {
              array-at(text-fill, level - 1)
            } else {
              text.fill
            }
            if effective-cover {
              utils.update-alpha(text-color, alpha)
            } else {
              text-color
            }
          })
          set text(
            size: array-at(text-size, level - 1),
          ) if type(text-size) == array and text-size.len() > 0
          set text(
            weight: array-at(text-weight, level - 1),
          ) if type(text-weight) == array and text-weight.len() > 0
          body
        }
        let body = {
          if type(vspace) == array and vspace.len() > it.level - 1 {
            v(vspace.at(it.level - 1))
          }
          h(range(1, it.level + 1).map(level => array-at(indent, level - 1)).sum())
          set-text(
            it.level,
            {
              if array-at(numbered, it.level - 1) {
                let current-numbering = numbering.at(
                  it.level - 1,
                  default: it.element.numbering,
                )
                if current-numbering != none {
                  std.numbering(
                    current-numbering,
                    ..counter(heading).at(it.element.location()),
                  )
                  h(.3em)
                }
              }
              link(
                it.element.location(),
                {
                  if short-heading {
                    utils.short-heading(self: self, it.element)
                  } else {
                    it.element.body
                  }
                  box(
                    width: 1fr,
                    inset: (x: .2em),
                    if array-at(filled, it.level - 1) {
                      array-at(fill, level - 1)
                    },
                  )
                  if array-at(paged, it.level - 1) {
                    std.numbering(
                      if page.numbering != none {
                        page.numbering
                      } else {
                        "1"
                      },
                      ..counter(page).at(it.element.location()),
                    )
                  }
                },
              )
            },
          )
        }
        if effective-cover {
          body
        } else {
          uncover-fn(body)
        }
      }

      // Three-state rendering when hide-other-sections-subsections is enabled:
      //   • Covered section-level entries           → alpha via build-styled-body(true)
      //   • Subsections in other sections           → hidden by entry-filter (never reach here)
      //   • Subsections in current section (active) → full colour via build-styled-body(false)
      //   • Subsections in current section (others) → alpha via build-styled-body(true)
      //
      // For the last two cases we need context to look up the current heading, so we
      // embed a context block directly in the returned content.
      if hide-other-sections-subsections and it.level > effective-level and not cover {
        context {
          let current-sub = utils.current-heading(level: it.level, hierachical: false)
          let is-active = (
            current-sub != none
              and current-sub.location().page() == it.element.location().page()
          )
          build-styled-body(not is-active)
        }
      } else {
        build-styled-body(cover)
      }
    },
    title: title,
    ..args,
  )
}


/// Show mini slides. It is usually used to show the navigation of the presentation in header.
///
/// - self (none): The self context, which is used to get the short heading of the headings.
///
/// - fill (color): The fill color of the headings. Default is `rgb("000000")`.
///
/// - alpha (ratio): The transparency of the headings. Default is `60%`.
///
/// - display-section (boolean): Indicates whether the sections should be displayed. Default is `false`.
///
/// - display-subsection (boolean): Indicates whether the subsections should be displayed. Default is `true`.
///
/// - linebreaks (boolean): Indicates whether or not to insert linebreaks between links for sections and subsections.
///
/// - display-subsection (boolean): Indicates whether the subsections should be displayed. Default is `true`.
///
/// - short-heading (boolean): Indicates whether the headings should be shortened. Default is `true`.
///
/// - inline (boolean): Indicates whether the bullets are displayed right after the text, instead of breaking the line. Default is `false`.
///
/// -> content
#let mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  short-heading: true,
  inline: false,
) = (
  context {
    let headings = query(
      heading.where(level: 1).or(heading.where(level: 2)),
    ).filter(it => it.outlined)
    let sections = headings.filter(it => it.level == 1)
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide")
        and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let current-index = (
      sections.filter(it => it.location().page() <= current-page).len() - 1
    )
    let cols = ()
    let col = ()
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
      let next-page = if next-hd != none {
        next-hd.location().page()
      } else {
        calc.inf
      }
      if hd.level == 1 {
        if col != () {
          cols.push(align(left, col.sum()))
          col = ()
        }
        col.push({
          let body = if short-heading {
            utils.short-heading(self: self, hd)
          } else {
            hd.body
          }
          [#link(hd.location(), body)<touying-link>]
          if inline {
            h(.5em)
          } else {
            linebreak()
          }
          while (
            slides.len() > 0 and slides.at(0).location().page() < next-page
          ) {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if (
                slide.location().page() <= current-page
                  and current-page < next-slide-page
              ) {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle.small)<touying-link>]
              }
            }
          }
          if display-section and display-subsection and linebreaks {
            linebreak()
          }
        })
      } else {
        col.push({
          while (
            slides.len() > 0 and slides.at(0).location().page() < next-page
          ) {
            let slide = slides.remove(0)
            if display-subsection {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if (
                slide.location().page() <= current-page
                  and current-page < next-slide-page
              ) {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle.small)<touying-link>]
              }
            }
          }
          if display-subsection and linebreaks {
            linebreak()
          }
        })
      }
    }
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }
    if current-index < 0 or current-index >= cols.len() {
      cols = cols.map(body => text(fill: fill, body))
    } else {
      cols = cols
        .enumerate()
        .map(pair => {
          let (idx, body) = pair
          if idx == current-index {
            text(fill: fill, body)
          } else {
            text(fill: utils.update-alpha(fill, alpha), body)
          }
        })
    }
    set align(top)
    show: block.with(inset: (top: .5em, x: if inline { 1em } else { 2em }))
    show linebreak: it => it + v(-1em)
    set text(size: .7em)
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)


/// Simple navigation.
///
/// - self (none): The self context, which is used to get the short heading of the headings.
///
/// - short-heading (boolean): Indicates whether the headings should be shortened. Default is `true`.
///
/// - primary (color): The color of the current section. Default is `white`.
///
/// - secondary (color): The color of the other sections. Default is `gray`.
///
/// - background (color): The background color of the navigation. Default is `black`.
///
/// - logo (none): The logo of the navigation. Default is `none`.
///
/// -> content
#let simple-navigation(
  self: none,
  short-heading: true,
  primary: white,
  secondary: gray,
  background: black,
  logo: none,
) = (
  context {
    let body() = {
      let sections = query(heading.where(level: 1, outlined: true))
      if sections.len() == 0 {
        return
      }
      let current-page = here().page()
      set text(size: 0.5em)
      for (section, next-section) in sections.zip(sections.slice(1) + (none,)) {
        set text(fill: if section.location().page() <= current-page
          and (
            next-section == none
              or current-page < next-section.location().page()
          ) {
          primary
        } else {
          secondary
        })
        box(inset: 0.5em)[#link(
          section.location(),
          if short-heading {
            utils.short-heading(self: self, section)
          } else {
            section.body
          },
        )<touying-link>]
      }
    }
    block(
      fill: background,
      inset: 0pt,
      outset: 0pt,
      grid(
        align: center + horizon,
        columns: (1fr, auto),
        rows: 1.8em,
        gutter: 0em,
        cell(
          fill: background,
          body(),
        ),
        block(fill: background, inset: 4pt, height: 100%, text(
          fill: primary,
          logo,
        )),
      ),
    )
  }
)


/// LaTeX-like knob marker for list
///
/// Example: `#set list(marker: components.knob-marker(primary: rgb("005bac")))`
///
/// - primary (color): The color of the marker.
///
/// -> content
#let knob-marker(primary: rgb("#005bac")) = box(
  width: 0.5em,
  place(
    dy: 0.1em,
    circle(
      fill: gradient.radial(
        primary.lighten(100%),
        primary.darken(40%),
        focal-center: (30%, 30%),
      ),
      radius: 0.25em,
    ),
  ),
)
