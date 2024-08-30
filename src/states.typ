// touying slide counters
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = context {
  last-slide-counter.final().first()
}

/// Get the progress of the current slide.
///
/// - `callback` is the callback function `ratio => { .. }` to get the progress of the current slide. The `ratio` is a float number between 0 and 1.
#let touying-progress(callback) = (
  context {
    if last-slide-counter.final().first() == 0 {
      callback(1.0)
      return
    }
    let ratio = calc.min(1.0, slide-counter.get().first() / last-slide-counter.final().first())
    callback(ratio)
  }
)


// slide note state
#let slide-note-state = state("touying-slide-note-state", none)
#let current-slide-note = context slide-note-state.get()


// -------------------------------------
// Headings
// -------------------------------------

/// Get the current heading On or before the current page.
///
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
#let current-heading(level: auto, hierachical: true, depth: 9999) = {
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = query(heading).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = query(heading).filter(h => h.location().page() <= current-page and h.level <= depth)
  if headings == () {
    return
  }
  if level == auto {
    return headings.last()
  }
  let current-level = headings.last().level
  let current-heading = headings.pop()
  while headings.len() > 0 and level < current-level {
    current-level = headings.last().level
    current-heading = headings.pop()
  }
  if level == current-level {
    return current-heading
  }
}


/// Display the current heading on the page.
///
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - `sty` is the style of the heading. If `sty` is a function, it will use the function to style the heading. For example, `sty: current-heading => current-heading.body`.
#let display-current-heading(level: auto, hierachical: true, depth: 9999, ..sty) = (
  context {
    let sty = if sty.pos().len() > 1 {
      sty.pos().at(0)
    } else {
      current-heading => {
        if current-heading.numbering != none {
          numbering(current-heading.numbering, ..counter(heading).at(current-heading.location())) + h(.3em)
        }
        current-heading.body
      }
    }
    let current-heading = current-heading(level: level, hierachical: hierachical, depth: depth)
    if current-heading != none {
      sty(current-heading)
    }
  }
)


// -------------------------------------
// Saved states and counters
// -------------------------------------

#let saved-frozen-states = state("touying-saved-frozen-states", ())
#let saved-default-frozen-states = state("touying-saved-default-frozen-states", ())
#let saved-frozen-counters = state("touying-saved-frozen-counters", ())
#let saved-default-frozen-counters = state("touying-saved-default-frozen-counters", ())