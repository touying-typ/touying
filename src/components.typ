#import "utils.typ"


#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)


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