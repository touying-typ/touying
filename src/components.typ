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