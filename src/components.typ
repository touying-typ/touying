#import "utils.typ"


#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, outset: 0pt, breakable: false)


/// Touying progress bar.
///
/// - `primary` is the color of the progress bar.
///
/// - `secondary` is the color of the background of the progress bar.
///
/// - `height` is the height of the progress bar, optional. Default is `2pt`.
#let progress-bar(height: 2pt, primary, secondary) = utils.touying-progress(ratio => {
  grid(
    columns: (ratio * 100%, 1fr),
    rows: height,
    cell(fill: primary), cell(fill: secondary),
  )
})


/// Left and right.
///
/// - `left` is the content of the left part.
///
/// - `right` is the content of the right part.
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
#let checkerboard(columns: none, rows: none, ..bodies) = {
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
    panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(
      bodies.len(),
    ) + ")")
  }
  let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
  let color-body(idx-body) = {
    let (idx, body) = idx-body
    let (row, col) = cart-idx(idx)
    let color = if calc.even(row + col) {
      white
    } else {
      silver
    }
    set align(center + horizon)
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
/// - `alpha` is the transparency of the other sections. Default is `60%`.
///
/// - `level` is the level of the outline. Default is `1`.
///
/// - `transform` is the transformation applied to the text of the outline. It should take the following arguments:
///
///   - `cover` is a boolean indicating whether the current entry should be covered.
///
///   - `..args` are the other arguments passed to the `progressive-outline`.
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
    let current-heading = utils.current-heading(level: level)
    if current-heading != none {
      start-page = current-heading.location().page()
      if level != auto {
        let next-headings = query(
          selector(heading.where(level: level)).after(inclusive: false, current-heading.location()),
        )
        if next-headings != () {
          end-page = next-headings.at(0).location().page()
        }
      } else {
        end-page = start-page + 1
      }
    }
    show outline.entry: it => transform(
      cover: it.element.location().page() < start-page or it.element.location().page() >= end-page,
      level: level,
      alpha: alpha,
      ..args,
      it,
    )

    outline(..args)
  }
)


/// Show a custom progressive outline.
///
/// - `self` is the self context.
///
/// - `alpha` is the transparency of the other headings. Default is `60%`.
///
/// - `level` is the level of the outline. Default is `auto`.
///
/// - `numbered` is a boolean array indicating whether the headings should be numbered. Default is `false`.
///
/// - `filled` is a boolean array indicating whether the headings should be filled. Default is `false`.
///
/// - `paged` is a boolean array indicating whether the headings should be paged. Default is `false`.
///
/// - `text-fill` is an array of colors for the text fill of the headings. Default is `none`.
///
/// - `text-size` is an array of sizes for the text of the headings. Default is `none`.
///
/// - `text-weight` is an array of weights for the text of the headings. Default is `none`.
///
/// - `vspace` is an array of vertical spaces above the headings. Default is `none`.
///
/// - `title` is the title of the outline. Default is `none`.
///
/// - `indent` is an array of indentations for the headings. Default is `(0em, )`.
///
/// - `fill` is an array of fills for the headings. Default is `repeat[.]`.
///
/// - `short-heading` is a boolean indicating whether the headings should be shortened. Default is `true`.
///
/// - `uncover-fn` is a function that takes the body of the heading and returns the body of the heading when it is uncovered. Default is the identity function.
///
/// - `..args` are the other arguments passed to the `progressive-outline` and `transform`.
#let custom-progressive-outline(
  self: none,
  alpha: 60%,
  level: auto,
  numbered: (false,),
  filled: (false,),
  paged: (false,),
  text-fill: none,
  text-size: none,
  text-weight: none,
  vspace: none,
  title: none,
  indent: (0em,),
  fill: (repeat[.],),
  short-heading: true,
  uncover-fn: body => body,
  ..args,
) = progressive-outline(
  alpha: alpha,
  level: level,
  transform: (cover: false, alpha: alpha, ..args, it) => {
    let array-at(arr, idx) = arr.at(idx, default: arr.last())
    let set-text(level, body) = {
      set text(fill: (
        if cover {
          utils.update-alpha(array-at(text-fill, level - 1), alpha)
        } else {
          array-at(text-fill, level - 1)
        }
      )) if type(text-fill) == array and text-fill.len() > 0
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
            numbering(it.element.numbering, ..counter(heading).at(it.element.location()))
            h(.3em)
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
                numbering(
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
    if cover {
      body
    } else {
      uncover-fn(body)
    }
  },
  title: title,
  ..args,
)



#let mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  short-heading: true,
) = (
  context {
    let headings = query(heading.where(level: 1).or(heading.where(level: 2)))
    let sections = headings.filter(it => it.level == 1)
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let current-index = sections.filter(it => it.location().page() <= current-page).len() - 1
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
          linebreak()
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-section and display-subsection {
            linebreak()
          }
        })
      } else {
        col.push({
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-subsection {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-subsection {
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
      cols = cols.enumerate().map(pair => {
        let (idx, body) = pair
        if idx == current-index {
          text(fill: fill, body)
        } else {
          text(fill: utils.update-alpha(fill, alpha), body)
        }
      })
    }
    set align(top)
    show: block.with(inset: (top: .5em, x: 2em))
    show linebreak: it => it + v(-1em)
    set text(size: .7em)
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)