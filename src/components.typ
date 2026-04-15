#import "utils.typ"
#import "magic.typ": warning

#let cell = block.with(
  width: 100%,
  height: 100%,
  above: 0pt,
  below: 0pt,
  outset: 0pt,
  breakable: false,
)


/// Lazy fractional vertical space, used with `lazy-layout` to push content to the
/// bottom of a block while keeping sibling blocks at equal height without filling the
/// entire page.
///
/// Has no visual effect without `lazy-layout`. If a column contains multiple `lazy-v`
/// markers (stacked blocks), only the last one is activated.
///
/// Example:
/// ```typ
/// #components.lazy-layout(grid(
///   columns: (1fr, 1fr),
///   block(width: 100%)[
///     #lorem(10)
///     #components.lazy-v(1fr)
///     Bottom left.
///   ],
///   block(width: 100%)[
///     #lorem(20)
///     #components.lazy-v(1fr)
///     Bottom right.
///   ],
/// ))
/// ```
///
/// - amount (fraction): The fractional amount of space (e.g. `1fr`).
///
/// - weak (bool): Whether the space is weak. Default is `false`.
///
/// -> content
#let lazy-v(amount, weak: false) = {
  assert(
    type(amount) == fraction,
    message: "lazy-v: `amount` must be a fraction (e.g. 1fr), got "
      + repr(amount),
  )
  [#parbreak()#metadata((
      amount: amount,
      weak: weak,
    ))<touying-lazy-v>#parbreak()]
}

/// Lazy fractional horizontal space, the horizontal counterpart of `lazy-v`.
/// Used with `lazy-layout(direction: ltr)` to push content to the right edge of a
/// block while keeping sibling blocks at equal width without filling the entire page.
///
/// Has no visual effect without a matching `lazy-layout`. If a row contains multiple
/// `lazy-h` markers (stacked blocks), only the last one is activated.
///
/// Example:
/// ```typ
/// #components.lazy-layout(
///   direction: ltr,
///   stack(
///     dir: ltr,
///     block(height: 100%)[
///       Left label. #components.lazy-h(1fr) Right label.
///     ],
///     block(height: 100%)[
///       A longer left label. #components.lazy-h(1fr) Right label.
///     ],
///   ),
/// )
/// ```
///
/// - amount (fraction): The fractional amount of space (e.g. `1fr`).
///
/// - weak (bool): Whether the space is weak. Default is `false`.
///
/// -> content
#let lazy-h(amount, weak: false) = {
  assert(
    type(amount) == fraction,
    message: "lazy-h: `amount` must be a fraction (e.g. 1fr), got "
      + repr(amount),
  )
  [#metadata((
    amount: amount,
    weak: weak,
  ))<touying-lazy-h>]
}

/// Make multiple blocks match the size of the tallest (or widest) sibling without
/// expanding to fill the entire page.
///
/// - `direction: ttb` (default): equalizes block *heights* via `lazy-v`.
/// - `direction: ltr`: equalizes block *widths* via `lazy-h`.
///
/// If a column (or row) contains multiple lazy markers (stacked blocks), only the last
/// one is activated.
///
/// Use `side-by-side(lazy-layout: true)` as a convenient shorthand for the vertical case.
///
/// ```typ
/// #components.lazy-layout(grid(
///   columns: (1fr, 1fr),
///   block(width: 100%)[
///     #lorem(10)
///     #components.lazy-v(1fr)
///     Bottom left.
///   ],
///   block(width: 100%)[
///     #lorem(20)
///     #components.lazy-v(1fr)
///     Bottom right.
///   ],
/// ))
/// ```
///
/// - direction (direction): The equalization axis (`ttb`/`btt` for heights, `ltr`/`rtl` for widths). Default is `ttb`.
///
/// - body (content): The content containing `lazy-v` or `lazy-h` markers.
///
/// -> content
#let lazy-layout(direction: ttb, body) = {
  [#metadata((:))<lazy-layout-begin>]
  layout(container-size => context {
    // Query lazy marker positions within this lazy-layout scope.
    let begin-loc = query(selector(<lazy-layout-begin>).before(here()))
      .last()
      .location()
    let end-loc = query(selector(<lazy-layout-end>).after(here()))
      .first()
      .location()

    let is-vertical = direction.axis() == "vertical"
    if is-vertical {
      // Collect positions of all lazy-v markers in this scope.
      let lazy-v-items = query(
        selector(<touying-lazy-v>).after(begin-loc).before(end-loc),
      )
      let lazy-v-positions = lazy-v-items.map(it => it.location().position())
      // For each x coordinate, find the last marker's position (the one to activate).
      // Group by x and keep only the last position per group.
      let last-positions = {
        let result = (:)
        for pos in lazy-v-positions {
          let key = repr(pos.x)
          result.insert(key, pos)
        }
        result.values()
      }

      // Phase 1: measure height with all lazy-v markers hidden.
      let measured-size = measure(block(
        width: container-size.width,
        body,
      ))
      // Phase 2: render at the measured height.
      // Only the last lazy-v marker per x coordinate is activated; others stay hidden.
      show <touying-lazy-h>: it => panic(
        "lazy-layout: found a lazy-h marker inside a vertical lazy-layout. "
          + "Use lazy-v markers for vertical layouts, or pass direction: ltr to lazy-layout.",
      )
      show <touying-lazy-v>: it => {
        let pos = it.location().position()
        if last-positions.any(lp => lp.x == pos.x and lp.y == pos.y) {
          v(it.value.amount, weak: it.value.weak)
        }
      }
      block(height: measured-size.height, body)
    } else {
      // Collect positions of all lazy-h markers in this scope.
      let lazy-h-items = query(
        selector(<touying-lazy-h>).after(begin-loc).before(end-loc),
      )
      let lazy-h-positions = lazy-h-items.map(it => it.location().position())
      // For each y coordinate, find the last marker's position (the one to activate).
      let last-positions = {
        let result = (:)
        for pos in lazy-h-positions {
          let key = repr(pos.y)
          result.insert(key, pos)
        }
        result.values()
      }

      // Phase 1: measure width with all lazy-h markers hidden.
      let measured-size = measure(block(
        height: container-size.height,
        body,
      ))
      // Phase 2: render at the measured width.
      // Only the last lazy-h marker per y coordinate is activated; others stay hidden.
      show <touying-lazy-v>: it => panic(
        "lazy-layout: found a lazy-v marker inside a horizontal lazy-layout. "
          + "Use lazy-h markers for horizontal layouts, or pass direction: ttb to lazy-layout.",
      )
      show <touying-lazy-h>: it => {
        let pos = it.location().position()
        if last-positions.any(lp => lp.y == pos.y and lp.x == pos.x) {
          h(it.value.amount, weak: it.value.weak)
        }
      }
      block(width: measured-size.width, body)
    }
  })
  [#metadata((:))<lazy-layout-end>]
}

// Alias used inside `side-by-side` to avoid the `lazy-layout` parameter shadowing the function.
#let _lazy-layout = lazy-layout

/// A simple wrapper around `grid` that creates a single-row grid. Used as the default `composer` for multi-body slides.
///
/// Example: `side-by-side[a][b][c]` will display `a`, `b`, and `c` side by side.
///
/// - columns (auto, array): The column widths. Default is `auto`, which creates equal-width columns matching the number of bodies.
///
/// - gutter (length): The space between columns. Default is `1em`.
///
/// - lazy-layout (bool): When `true`, wraps the grid with `lazy-layout` so that
///   `lazy-v` markers inside the bodies are resolved correctly. Default is `true`.
///
/// - bodies (content): The contents to display side by side.
///
/// -> content
#let side-by-side(columns: auto, gutter: 1em, lazy-layout: true, ..bodies) = {
  let args = bodies.named()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return if lazy-layout {
      _lazy-layout(bodies.first())
    } else {
      bodies.first()
    }
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  let result = grid(columns: columns, gutter: gutter, ..args, ..bodies)
  if lazy-layout {
    _lazy-layout(result)
  } else {
    result
  }
}


/// Adaptive columns layout that automatically chooses the number of columns based on content height.
///
/// Example: `components.adaptive-columns(outline())`
///
/// - gutter (length): The space between columns. Default is `4%`.
///
/// - max-count (int): The maximum number of columns. Default is `3`.
///
/// - start (content, none): The content to place before the columns. Default is `none`.
///
/// - end (content, none): The content to place after the columns. Default is `none`.
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


/// Place two content blocks at the left and right edges of the available width using a three-column grid.
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


/// Create a slide where the provided content blocks are displayed in a grid with a checkerboard color pattern.
///
/// You can configure the grid using the `rows` and `columns` keyword arguments (both default to `none`):
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create as many rows of height `1fr` as needed given the number of content blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
///
/// That means that `#checkerboard[...][...]` stacks horizontally and `#checkerboard(columns: 1)[...][...]` stacks vertically.
///
/// - columns (int, array, none): The column specification. Default is `none`.
///
/// - rows (int, array, none): The row specification. Default is `none`.
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
/// - alpha (ratio): The transparency of the other sections. Default is `60%`.
///
/// - level (int): The level of the outline. Default is `1`.
///
/// - transform (function): A function applied to each outline entry. It receives `(cover: bool, level: int, alpha: ratio, ..args, it)` where `cover` is `true` when the entry should be visually de-emphasized, `it` is the outline entry element, and `alpha` is the transparency value.
///
/// - args (arguments): Additional arguments forwarded to the inner `outline()` call, see https://typst.app/docs/reference/model/outline/.
///
/// -> content
#let progressive-outline(
  alpha: 60%,
  level: 1,
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
    show outline.entry: it => transform(
      cover: it.element.location().page() < start-page
        or it.element.location().page() >= end-page,
      level: level,
      alpha: alpha,
      ..args,
      it,
    )

    outline(..args)
  }
)


/// A fully-featured progressive outline that renders headings from multiple levels with per-level styling.
///
/// Uses arrays indexed by heading level (first element = level 1, second = level 2, etc.) to apply different styling to each level. Unlike `progressive-outline` (a thin wrapper around Typst's built-in `outline`), this function renders each heading manually, giving full control over numbering, indentation, fills, and typography.
/// For styling parameters the last value in the array is used for all levels beyond the array length, it is repeated. So you can write `indent: (1em,)` to apply a `1em` indentation to all levels, or `indent: (0em, 1em)` to apply no indentation to level-1 headings and `1em` to level-2 and beyond. This is not the case for `numbering` or `vspace` nor for `filled`, `numbered`, `paged`.
///
/// - self (none): The self context.
///
/// - alpha (ratio): The transparency of the covered headings. Default is `60%`.
///
/// - level (auto, int): The outline level. When `auto`, all levels up to `slide-level` are shown. Default is `auto`.
///
/// - numbered (array): Per-level booleans indicating whether headings are numbered. Default is `(false,)`. *Last value in the array is not-repeated!*
///
/// - filled (array): Per-level booleans indicating whether to show a fill between the heading and the page number. Default is `(false,)`. *Last value in the array is not-repeated!*
///
/// - paged (array): Per-level booleans indicating whether to show the page number. Default is `(false,)`. *Last value in the array is not-repeated!*
///
/// - numbering (array): Per-level numbering strings or `none` overrides. Default is `()`. *Last value in the array is not-repeated!*
///
/// - text-style (array, none): Per-level text style dicts. Default is `none` (inherits current text style). See the parameters of `text` (https://typst.app/docs/reference/text/text/).
///
/// - vspace (array, none): Per-level vertical space above each heading. Default is `none`. *Last value in the array is not-repeated!*
///
/// - title (str, none): The title of the outline section. Default is `none`.
///
/// - indent (array): Per-level left indentation. Default is `(0em,)`.
///
/// - fill (array): Per-level fill content between heading and page number. Default is `(repeat[.],)`.
///
/// - short-heading (bool): Whether to shorten headings that have labels using `utils.short-heading`. Default is `true`.
///
/// - show-past (array, function, none): Per-level booleans indicating whether to show headings for past sections. Default is `none`, reverts to the cover behaviour of `progressive-outline`. The last value in the array is used for all levels beyond the array length. \ If a function is provided instead, the function is used to style the outline entries and the styles passed to custom-progressive-outline are ignored. It receives `(level: int, it)` where `it` is the outline entry element and `level` is the heading level of that entry.
///
/// - show-current (array, function, none): Per-level booleans. Defaul is `none`. For more info see `show-past`.
///
/// - show-future (array, function, none): Per-level booleans. Default is `none`. For more info see `show-past`.
///
/// - style-current (array): Per level text style dicts which override text styles for the non-covered headings. Default is `none`, which uses the styles from `text-style`. See `text-style` for more details.
///
/// - args (arguments): Additional arguments forwarded to the underlying `outline` call, see https://typst.app/docs/reference/model/outline/.
///
/// -> content
#let custom-progressive-outline(
  self: none,
  alpha: 60%,
  level: auto,
  numbered: (false,), //only applies when headings have numbering in the document
  filled: (false,),
  paged: (false,),
  numbering: (), // only when numbered is true, overrides the document numbering for the outline
  text-style: none,
  vspace: none, // set to (0pt, ...) to linebreak the entries
  title: none, //if set the outline will create its own top level heading
  indent: (0em,),
  fill: (repeat[.],),
  short-heading: true,
  show-past: none,
  show-current: none,
  show-future: none,
  style-current: none,
  ..args,
) = {
  // panic when args has uncover-fn
  if "uncover-fn" in args.named().keys() {
    panic(
      "uncover-fn is no longer supported in custom-progressive-outline, use style-current instead.",
    )
  }
  let named-args = args.named()
  //for backwards compatibility, we extract text-fill, text-size and text-weight from the args and pass it into text-style
  let merge-dep-styles(base, override, name) = {
    let result = if base != none { base } else { () }
    if override.len() > result.len() {
      result = result + (range(override.len() - result.len()).map(i => (:))) //Extend result with empty dicts
    }
    for i in range(override.len()) {
      if override.at(i) != none {
        result.at(i).insert(name, override.at(i))
      }
    }
    result
  }
  let dep-text-fill = named-args.remove("text-fill", default: ())
  let dep-text-size = named-args.remove("text-size", default: ())
  let dep-text-weight = named-args.remove("text-weight", default: ())
  if (
    not dep-text-fill == ()
      or not dep-text-size == ()
      or not dep-text-weight == ()
  ) {
    warning(
      "Passing text-fill, text-size or text-weight to custom-progressive-outline will be deprecated in some future version. Use text-style instead.",
    )
  }
  text-style = merge-dep-styles(text-style, dep-text-fill, "fill")
  text-style = merge-dep-styles(text-style, dep-text-size, "size")
  text-style = merge-dep-styles(text-style, dep-text-weight, "weight")

  // now the actualy function
  if level == auto {
    level = if self != none { self.at("slide-level", default: 1) } else { 1 }
  }

  let array-at(arr, idx, d: none) = arr.at(idx, default: if arr.len() > 0 {
    arr.last()
  } else { d }) //with last as default

  let set-text(cover, level, alpha, body) = {
    let style-at-lvl = if not cover and type(style-current) == array {
      array-at(style-current, level - 1, d: (:))
    } else if type(text-style) == array {
      array-at(text-style, level - 1, d: (:))
    } else {
      (:)
    }
    if cover {
      style-at-lvl.insert("fill", utils.update-alpha(
        style-at-lvl.at("fill", default: text.fill),
        alpha,
      ))
    }
    set text(..style-at-lvl)
    body
  }

  let position(level) = {
    let start-page = 1
    let end-page = calc.inf
    if level != none {
      let current-heading = utils.current-heading(level: level)
      if current-heading != none {
        start-page = current-heading.location().page()
        let headings-up-to(level) = {
          if level <= 1 {
            return heading.where(level: level)
          } else {
            return heading.where(level: level).or(headings-up-to(level - 1))
          }
        }
        let next-headings = query(
          selector(headings-up-to(level)).after(
            inclusive: false,
            current-heading.location(),
          ),
        ).at(0, default: none)
        end-page = if next-headings != none {
          next-headings.location().page()
        } else {
          calc.inf
        }
      }
    }
    return (start-page, end-page)
  }

  let transform(cover: false, alpha: alpha, it) = {
    if type(vspace) == array and vspace.len() > it.level - 1 {
      v(vspace.at(it.level - 1))
    }

    h(
      range(1, it.level + 1)
        .map(level => array-at(indent, level - 1, d: 0%))
        .sum(),
    )
    set-text(
      cover,
      it.level,
      alpha,
      {
        if array-at(numbered, it.level - 1, d: false) {
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
              if array-at(filled, it.level - 1, d: false) {
                array-at(fill, it.level - 1, d: repeat[.])
              },
            )
            if array-at(paged, it.level - 1, d: false) {
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

  context {
    let doc-pos = position(level)
    show outline.entry: it => {
      let cur-pos = it.element.location().page()

      if cur-pos < doc-pos.first() {
        if type(show-past) == function {
          return show-past(it.level, it)
        } else if (
          type(show-past) == array
            and not array-at(show-past, it.level - 1, d: false)
        ) {
          return none
        } else {
          //if show or show-past is none
          transform(cover: true, alpha: alpha, it)
        }
      } else if cur-pos >= doc-pos.last() {
        if type(show-future) == function {
          return show-future(it.level, it)
        } else if (
          type(show-future) == array
            and not array-at(show-future, it.level - 1, d: false)
        ) {
          return none
        } else {
          //if show or show-future is none
          return transform(cover: true, alpha: alpha, it)
        }
      } else {
        if type(show-current) == function {
          return show-current(it.level, it)
        } else if (
          type(show-current) == array
            and not array-at(show-current, it.level - 1, d: false)
        ) {
          return none
        } else {
          //if show or show-current is none
          return transform(cover: false, alpha: alpha, it)
        }
      }
    }
    outline(title: title, ..named-args, ..args.pos())
  }
}

/// Section navigation component showing all sections and their per-slide progress as small filled/empty circle dots.
///
/// Typically placed in a theme's page header. Each section is labeled with a link, and each slide within the section is represented by a small dot (filled for the current slide, hollow for others). The active section uses the full `fill` color; inactive sections have `alpha` transparency applied.
///
/// - self (none): The self context, used to resolve short headings.
///
/// - fill (color): The text and dot color. Default is `rgb("000000")`.
///
/// - alpha (ratio): The transparency applied to inactive sections. Default is `60%`.
///
/// - display-section (bool): Whether to show per-slide dots for level-1 section headings. Default is `false`.
///
/// - display-subsection (bool): Whether to show per-slide dots for level-2 subsection headings. Default is `true`.
///
/// - linebreaks (bool): Whether to insert a line break after section/subsection labels. Default is `true`.
///
/// - short-heading (bool): Whether to shorten heading labels using `utils.short-heading`. Default is `true`.
///
/// - inline (bool): Whether to place dots on the same line as the section label instead of below it. Default is `false`.
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


/// A horizontal navigation bar showing all level-1 sections as clickable links.
///
/// The active section label is shown in `primary` color; all other sections use `secondary` color. An optional logo is placed at the right edge. Typically used as a page header in themes.
///
/// - self (none): The self context, used to resolve short headings.
///
/// - short-heading (bool): Whether to shorten heading labels using `utils.short-heading`. Default is `true`.
///
/// - primary (color): The text color of the currently active section. Default is `white`.
///
/// - secondary (color): The text color of inactive sections. Default is `gray`.
///
/// - background (color): The background fill of the navigation bar. Default is `black`.
///
/// - logo (content, none): Optional logo displayed at the right side of the bar. Default is `none`.
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


/// LaTeX-like knob marker for list items.
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

/// A non-breakable page container that prevents slide content from overflowing
/// to the next page. When used, content that exceeds the slide height will be
/// constrained rather than creating additional pages.
///
/// This is useful for ensuring a strict one-to-one mapping between source
/// slides and output pages, which is important in agentic workflows where
/// an agent needs to reason about slide boundaries.
///
/// - clip (bool): Whether to clip overflowing content. When `true`, content
///   that exceeds the slide height will be visually truncated. Default is `false`.
///
/// - detect-overflow (bool): Whether to detect and warn on overflow. When `true`,
///   a `layout` + `measure` check is performed and a warning is emitted if the
///   content height exceeds the available container height. When `false`, no
///   overflow detection is performed (avoids the `layout` overhead). Default is `false`.
///
/// - body (content): The slide content to constrain within a single page.
///
/// -> content
#let page-container(self: none, clip: false, detect-overflow: false, body) = {
  let tight-block-args = (
    above: 0pt,
    below: 0pt,
    inset: (:),
    outset: (:),
    radius: (:),
    spacing: 0pt,
    sticky: false,
    stroke: (:),
  )
  if detect-overflow {
    // Detect and warn on overflow
    layout(container-size => {
      let content-size = measure(block(
        ..tight-block-args,
        width: container-size.width,
        body,
      ))
      let content-height = content-size.height
      let available-height = container-size.height
      if content-height > available-height {
        warning(
          "detecting slide content overflow at page "
            + repr(here().page())
            + " (slide "
            + str(utils.slide-counter.get().last())
            + ", subslide "
            + str(self.subslide)
            + ", content height: "
            + repr(content-height)
            + ", available height: "
            + repr(available-height)
            + ").",
        )
      } else if content-height == 0pt {
        warning(
          "detecting slide content is empty at page "
            + repr(here().page())
            + " (slide "
            + str(utils.slide-counter.get().last())
            + ", subslide "
            + str(self.subslide)
            + ", content height: "
            + repr(content-height)
            + ", available height: "
            + repr(available-height)
            + ").",
        )
      }
    })
  }
  // Disable breakability to prevent overflowing content from creating new pages
  block(
    ..tight-block-args,
    breakable: false,
    clip: clip,
    height: 1fr,
    width: 100%,
    body,
  )
}
