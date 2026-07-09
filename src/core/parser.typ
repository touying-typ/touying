#import "../utils.typ"
#import "waypoints.typ": (
  _compute-waypoint-ranges, _cover-never, _resolve-waypoint-forest,
  _waypoint-known, waypoint-kinds,
)

/// Parse touying reducer content and extract animation repetitions
///
/// Processes reducer content (used for external packages like CeTZ, Fletcher)
/// with pause and meanwhile markers.
///
/// - self (dictionary): The presentation context
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - reducer (dictionary): The reducer configuration
///
/// -> (array, int)
#let _parse-touying-reducer(self: none, base: 1, index: 1, reducer) = {
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  let last-subslide = 0
  // get cover function from self
  let cover = reducer.cover
  // Build a modified self whose cover method uses the reducer's cover function,
  // so that fn-wrappers (uncover, only, etc.) cover items correctly for the
  // external package (e.g. fletcher.hide instead of the global hide).
  let reducer-self = utils.merge-dicts(
    self,
    (
      methods: utils.merge-dicts(
        self.at("methods", default: (:)),
        (cover: utils.method-wrapper(reducer.cover)),
      ),
    ),
  )
  // parse the content
  // Flatten content sequences so that e.g. uncover(<label>, body) which produces
  // [implicit-waypoint-metadata + fn-wrapper-metadata] is split into separate children.
  let flat-args = ()
  for arg in reducer.args.flatten() {
    if type(arg) == content and utils.is-sequence(arg) {
      flat-args += arg.children
    } else {
      flat-args.push(arg)
    }
  }
  let result = ()
  for child in flat-args {
    if (
      type(child) == content
        and child.func() == metadata
        and type(child.value) == dictionary
    ) {
      let kind = child.value.at("kind", default: none)
      if kind == "touying-jump/pause/meanwhile" {
        if child.value.relative {
          // Snap past any fn-wrapper range before applying the relative jump
          repetitions = calc.max(repetitions, last-subslide) + child.value.n
          // Track the peak repetitions so that a subsequent negative jump doesn't
          // cause the slide count to be underestimated
          max-repetitions = calc.max(max-repetitions, repetitions)
        } else {
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = child.value.n
          last-subslide = 0
        }
      } else if kind == "touying-waypoint" {
        // Waypoint inside reducer: advance repetitions if applicable.
        // Only implicit/explicit waypoints supported, no waypoint markers.
        // Never pushed to result.
        let wp = self.at("waypoints", default: (:))
        let lbl = child.value.label
        let wp-start = child.value.at("start", default: auto)
        if wp-start != auto and lbl in wp {
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = wp.at(lbl).first
          last-subslide = 0
        } else if (
          child.value.at("advance", default: true) and lbl in wp
        ) {
          let first = wp.at(lbl).first
          if (
            first == repetitions + 1
              or (first == last-subslide + 1 and first > repetitions)
          ) {
            repetitions = first
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
        }
      } else if kind == "touying-implicit-waypoint" {
        // Implicit waypoint inside reducer: same firing logic as the outer parser.
        let wp = self.at("waypoints", default: (:))
        let lbl = child.value.label
        if lbl in wp {
          let first = wp.at(lbl).first
          if (
            first == repetitions + 1
              or (first == last-subslide + 1 and first > repetitions)
          ) {
            repetitions = first
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
        }
      } else if kind == "touying-fn-wrapper" {
        // Handle function wrappers (uncover, only, alternatives, etc.)
        // These always escape the pause zone: they handle their own visibility.
        let extra-args = (:)
        if child.value.last-subslide != none {
          if type(child.value.last-subslide) == function {
            let (callback-last-subslide, callback-extra-args) = (
              child.value.last-subslide
            )(
              repetitions,
            )
            last-subslide = calc.max(last-subslide, callback-last-subslide)
            extra-args = callback-extra-args
          } else {
            last-subslide = calc.max(last-subslide, child.value.last-subslide)
          }
        }
        let fn-result = (child.value.fn)(
          self: reducer-self,
          ..child.value.args,
          ..extra-args,
        )
        // only() returns none when hidden — don't push none to the result.
        // Flatten arrays (CeTZ draw commands) and content sequences (e.g.
        // alternatives returning joined only() results) so the reduce function
        // sees the same flat items as it would in the callback pathway.
        if fn-result != none {
          if type(fn-result) == array {
            result += fn-result
          } else if (
            type(fn-result) == content and utils.is-sequence(fn-result)
          ) {
            for child in fn-result.children {
              result.push(child)
            }
          } else {
            result.push(fn-result)
          }
        }
      } else {
        if repetitions <= index {
          result.push(child)
        } else {
          let r = cover((child,))
          if type(r) == array { result += r } else { result.push(r) }
        }
      }
    } else {
      if repetitions <= index {
        result.push(child)
      } else {
        let r = cover((child,))
        if type(r) == array { result += r } else { result.push(r) }
      }
    }
  }
  // Safety net: filter out any remaining touying metadata nodes before passing
  // to the external reduce function (e.g. fletcher.diagram, cetz.canvas).
  // All touying metadata should already be handled above — if this filter
  // catches anything, it indicates a bug in the reducer's metadata handling.
  let leaked = result.filter(child => {
    if not (
      type(child) == content
        and child.func() == metadata
        and type(child.value) == dictionary
    ) {
      return false
    }
    let kind = child.value.at("kind", default: none)
    type(kind) == str and kind.starts-with("touying-")
  })
  if leaked.len() > 0 {
    let kinds = leaked.map(c => c.value.at("kind", default: "unknown"))
    assert(
      false,
      message: "touying internal bug: leaked metadata into reducer result: "
        + repr(kinds)
        + ". Please report this at https://github.com/touying-typ/touying/issues",
    )
  }
  parsed-results.push(
    (reducer.reduce)(
      ..reducer.kwargs,
      result,
    ),
  )
  max-repetitions = calc.max(max-repetitions, repetitions)
  max-repetitions = calc.max(max-repetitions, last-subslide)
  return (parsed-results, max-repetitions)
}


/// Count the peak repetition produced by an animated block (touying-equation,
/// touying-mitex, touying-raw, touying-reducer). Returns the max-repetitions
/// value, mirroring what the corresponding `_parse-touying-*` function would
/// return without needing `self` or cover logic.
///
/// - kind (str): The metadata kind.
/// - value (dictionary): The metadata value.
/// - base (int): The starting repetition count.
///
/// -> int
#let _count-animated-block-repetitions(kind, value, base) = {
  let repetitions = base
  let max-repetitions = repetitions

  if kind == "touying-reducer" {
    let last-subslide = 0
    // Reducer: iterate positional args looking for touying-jump/pause/meanwhile,
    // touying-waypoint, and touying-fn-wrapper metadata.
    // Flatten content sequences so that e.g. uncover(<label>, body) which produces
    // [implicit-waypoint-metadata + fn-wrapper-metadata] is split into separate children.
    let flat-count-args = ()
    for arg in value.args.flatten() {
      if type(arg) == content and utils.is-sequence(arg) {
        flat-count-args += arg.children
      } else {
        flat-count-args.push(arg)
      }
    }
    for child in flat-count-args {
      if (
        type(child) == content
          and child.func() == metadata
          and type(child.value) == dictionary
      ) {
        let k = child.value.at("kind", default: none)
        if k == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            // Snap past any fn-wrapper range before applying the relative jump
            repetitions = calc.max(repetitions, last-subslide) + child.value.n
            max-repetitions = calc.max(max-repetitions, repetitions)
          } else {
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = child.value.n
            last-subslide = 0
          }
        } else if k == "touying-waypoint" {
          if child.value.at("advance", default: true) {
            repetitions = calc.max(repetitions + 1, last-subslide + 1)
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
        } else if k == "touying-implicit-waypoint" {
          repetitions = calc.max(repetitions + 1, last-subslide + 1)
          max-repetitions = calc.max(max-repetitions, repetitions)
        } else if k == "touying-fn-wrapper" {
          let ls = child.value.at("last-subslide", default: none)
          if ls != none {
            if type(ls) == function {
              let (callback-ls, _) = ls(repetitions)
              last-subslide = calc.max(last-subslide, callback-ls)
            } else if type(ls) == int {
              last-subslide = calc.max(last-subslide, ls)
            }
          }
        }
      }
    }
    return calc.max(max-repetitions, repetitions, last-subslide)
  }

  // Text-based blocks: equation, mitex, raw
  let body = value.body
  if type(body) == function {
    // Cannot evaluate callback bodies during pre-pass (no self context).
    return base
  }
  if type(body) != str {
    return base
  }

  if kind == "touying-equation" {
    let parts = body
      .split(regex("(#meanwhile;?)|(meanwhile)"))
      .intersperse("touying-meanwhile")
      .map(s => s
        .split(regex("(#pause;?)|(pause)"))
        .intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      }
    }
  } else if kind == "touying-mitex" {
    let parts = body
      .split(regex("\\\\meanwhile"))
      .intersperse("touying-meanwhile")
      .map(s => s.split(regex("\\\\pause")).intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      }
    }
  } else if kind == "touying-raw" {
    if value.at("simple", default: false) {
      let parts = body
        .split(regex("#meanwhile;"))
        .intersperse("touying-meanwhile")
        .map(s => s.split(regex("#pause;")).intersperse("touying-pause"))
        .flatten()
      for part in parts {
        if part == "touying-pause" {
          repetitions += 1
        } else if part == "touying-meanwhile" {
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        }
      }
    } else {
      let meaningful-chars-pattern = regex("[a-zA-Z0-9\u{4E00}-\u{9FFF}]+")
      for line in body.split("\n") {
        let meaningful = line
          .matches(meaningful-chars-pattern)
          .map(m => m.text)
          .join("")
        if meaningful == "pause" {
          repetitions += 1
        } else if meaningful == "meanwhile" {
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        }
      }
    }
  }
  calc.max(max-repetitions, repetitions)
}


/// Walk content children to collect waypoint declarations and track pause
/// positions. Returns `(repetitions, last-subslide, waypoints-dict, start-overrides, decl-reps)`
/// where `waypoints-dict` maps label strings to their raw subslide numbers,
/// `start-overrides` maps labels with explicit `start` to their start spec
/// (an int or a label string), and `decl-reps` maps labels to the effective
/// repetitions counter at the point of declaration in the content
/// (`calc.max(repetitions, last-subslide)`).
///
/// This mirrors the pause-tracking logic of `_parse-content-into-results-and-repetitions`
/// but does NOT handle covering or visibility — it is a lightweight pre-pass.
#let _collect-waypoints-impl(
  children,
  repetitions,
  last-subslide,
  waypoints,
  start-overrides,
  decl-reps,
) = {
  // Helper: register a new advancing waypoint at the correct position.
  // Uses max(repetitions+1, last-subslide+1) so that waypoints placed after a
  // multi-subslide fn-wrapper (e.g. item-by-item) land AFTER its full range,
  // not just one step past the last sequential pause.
  let register-advancing-wp(
    lbl,
    repetitions,
    last-subslide,
    waypoints,
    decl-reps,
  ) = {
    decl-reps.insert(lbl, calc.max(repetitions, last-subslide))
    let pos = calc.max(repetitions + 1, last-subslide + 1)
    repetitions = pos
    last-subslide = calc.max(last-subslide, pos)
    waypoints.insert(lbl, pos)
    (repetitions, last-subslide, waypoints, decl-reps)
  }

  // Helper: register a waypoint that has an explicit `start` parameter.
  // For int starts, applies jump effect immediately. For label refs, records
  // a placeholder position (resolved later by _resolve-waypoint-forest).
  let register-start-wp(
    lbl,
    wp-start,
    repetitions,
    last-subslide,
    waypoints,
    start-overrides,
    decl-reps,
  ) = {
    decl-reps.insert(lbl, calc.max(repetitions, last-subslide))
    start-overrides.insert(lbl, wp-start)
    if type(wp-start) == int {
      waypoints.insert(lbl, wp-start)
      repetitions = wp-start
      last-subslide = calc.max(last-subslide, wp-start)
    } else {
      // Label reference (string) — can't resolve yet, use placeholder
      waypoints.insert(lbl, repetitions)
    }
    (repetitions, last-subslide, waypoints, start-overrides, decl-reps)
  }

  for child in children {
    if utils.is-sequence(child) {
      (
        repetitions,
        last-subslide,
        waypoints,
        start-overrides,
        decl-reps,
      ) = _collect-waypoints-impl(
        child.children,
        repetitions,
        last-subslide,
        waypoints,
        start-overrides,
        decl-reps,
      )
    } else if (
      type(child) == content
        and child.func() == metadata
        and type(child.value) == dictionary
    ) {
      let kind = child.value.at("kind", default: none)
      if kind == "touying-jump/pause/meanwhile" {
        if child.value.relative {
          // Snap past any preceding fn-wrapper range before applying the
          // relative jump, so pauses after e.g. item-by-item land correctly.
          repetitions = calc.max(repetitions, last-subslide) + child.value.n
        } else {
          repetitions = child.value.n
          last-subslide = 0
        }
      } else if kind == "touying-waypoint" {
        if not _waypoint-known(waypoints, child.value.label) {
          let wp-start = child.value.at("start", default: auto)
          if wp-start != auto {
            (
              repetitions,
              last-subslide,
              waypoints,
              start-overrides,
              decl-reps,
            ) = register-start-wp(
              child.value.label,
              wp-start,
              repetitions,
              last-subslide,
              waypoints,
              start-overrides,
              decl-reps,
            )
          } else if child.value.at("advance", default: true) {
            (
              repetitions,
              last-subslide,
              waypoints,
              decl-reps,
            ) = register-advancing-wp(
              child.value.label,
              repetitions,
              last-subslide,
              waypoints,
              decl-reps,
            )
          } else {
            decl-reps.insert(child.value.label, calc.max(
              repetitions,
              last-subslide,
            ))
            waypoints.insert(child.value.label, repetitions)
          }
        }
      } else if kind == "touying-implicit-waypoint" {
        if not _waypoint-known(waypoints, child.value.label) {
          (
            repetitions,
            last-subslide,
            waypoints,
            decl-reps,
          ) = register-advancing-wp(
            child.value.label,
            repetitions,
            last-subslide,
            waypoints,
            decl-reps,
          )
        }
      } else if kind == "touying-set-config" {
        let inner = if utils.is-sequence(child.value.body) {
          child.value.body.children
        } else {
          (child.value.body,)
        }
        (
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        ) = _collect-waypoints-impl(
          inner,
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        )
      } else if kind in ("touying-equation", "touying-mitex", "touying-raw") {
        repetitions = _count-animated-block-repetitions(
          kind,
          child.value,
          repetitions,
        )
      } else if kind == "touying-reducer" {
        // Recurse into the reducer's positional args to find waypoints and track pauses.
        let inner-rep = repetitions
        let inner-max = repetitions
        let inner-ls = last-subslide
        let inner-flat-args = ()
        for arg in child.value.args.flatten() {
          if type(arg) == content and utils.is-sequence(arg) {
            inner-flat-args += arg.children
          } else {
            inner-flat-args.push(arg)
          }
        }
        for inner-child in inner-flat-args {
          if (
            type(inner-child) == content
              and inner-child.func() == metadata
              and type(inner-child.value) == dictionary
          ) {
            let ik = inner-child.value.at("kind", default: none)
            if ik == "touying-jump/pause/meanwhile" {
              if inner-child.value.relative {
                // Snap past any fn-wrapper range before applying the relative jump
                inner-rep = calc.max(inner-rep, inner-ls) + inner-child.value.n
                inner-max = calc.max(inner-max, inner-rep)
              } else {
                inner-max = calc.max(inner-max, inner-rep)
                inner-rep = inner-child.value.n
                inner-ls = 0
              }
            } else if ik == "touying-waypoint" {
              if not _waypoint-known(waypoints, inner-child.value.label) {
                let wp-start = inner-child.value.at("start", default: auto)
                if wp-start != auto {
                  (
                    inner-rep,
                    inner-ls,
                    waypoints,
                    start-overrides,
                    decl-reps,
                  ) = register-start-wp(
                    inner-child.value.label,
                    wp-start,
                    inner-rep,
                    inner-ls,
                    waypoints,
                    start-overrides,
                    decl-reps,
                  )
                } else if inner-child.value.at("advance", default: true) {
                  (
                    inner-rep,
                    inner-ls,
                    waypoints,
                    decl-reps,
                  ) = register-advancing-wp(
                    inner-child.value.label,
                    inner-rep,
                    inner-ls,
                    waypoints,
                    decl-reps,
                  )
                } else {
                  decl-reps.insert(inner-child.value.label, calc.max(
                    inner-rep,
                    inner-ls,
                  ))
                  waypoints.insert(inner-child.value.label, inner-rep)
                }
              }
            } else if ik == "touying-implicit-waypoint" {
              if not _waypoint-known(waypoints, inner-child.value.label) {
                (
                  inner-rep,
                  inner-ls,
                  waypoints,
                  decl-reps,
                ) = register-advancing-wp(
                  inner-child.value.label,
                  inner-rep,
                  inner-ls,
                  waypoints,
                  decl-reps,
                )
              }
            } else if ik == "touying-fn-wrapper" {
              // fn-wrappers can span multiple subslides via their last-subslide field.
              let ls = inner-child.value.at("last-subslide", default: none)
              if ls != none {
                if type(ls) == function {
                  let (callback-ls, _) = ls(inner-rep)
                  inner-ls = calc.max(inner-ls, callback-ls)
                } else if type(ls) == int {
                  inner-ls = calc.max(inner-ls, ls)
                }
              }
            }
          }
        }
        repetitions = calc.max(inner-max, inner-rep)
        last-subslide = calc.max(last-subslide, inner-ls)
      } else if kind == "touying-fn-wrapper" {
        // fn-wrappers can span multiple subslides via their last-subslide field.
        // Update last-subslide so that subsequent waypoints are placed AFTER
        // this fn-wrapper's full animation range, not just at repetitions+1.
        let ls = child.value.at("last-subslide", default: none)
        if ls != none {
          if type(ls) == function {
            let (callback-ls, _) = ls(repetitions)
            last-subslide = calc.max(last-subslide, callback-ls)
          } else if type(ls) == int {
            last-subslide = calc.max(last-subslide, ls)
          }
        }
      }
    } else if utils.is-styled(child) {
      (
        repetitions,
        last-subslide,
        waypoints,
        start-overrides,
        decl-reps,
      ) = _collect-waypoints-impl(
        (child.child,),
        repetitions,
        last-subslide,
        waypoints,
        start-overrides,
        decl-reps,
      )
    } else if (
      type(child) == content and child.func() in (table.cell, grid.cell)
    ) {
      // Handle table/grid cells that may wrap jump or waypoint metadata
      if (
        type(child.body) == content
          and child.body.func() == metadata
          and type(child.body.value) == dictionary
      ) {
        let kind = child.body.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if child.body.value.relative {
            repetitions = (
              calc.max(repetitions, last-subslide) + child.body.value.n
            )
          } else {
            repetitions = child.body.value.n
            last-subslide = 0
          }
        } else if kind == "touying-waypoint" {
          if not _waypoint-known(waypoints, child.body.value.label) {
            let wp-start = child.body.value.at("start", default: auto)
            if wp-start != auto {
              (
                repetitions,
                last-subslide,
                waypoints,
                start-overrides,
                decl-reps,
              ) = register-start-wp(
                child.body.value.label,
                wp-start,
                repetitions,
                last-subslide,
                waypoints,
                start-overrides,
                decl-reps,
              )
            } else if child.body.value.at("advance", default: true) {
              (
                repetitions,
                last-subslide,
                waypoints,
                decl-reps,
              ) = register-advancing-wp(
                child.body.value.label,
                repetitions,
                last-subslide,
                waypoints,
                decl-reps,
              )
            } else {
              decl-reps.insert(child.body.value.label, calc.max(
                repetitions,
                last-subslide,
              ))
              waypoints.insert(child.body.value.label, repetitions)
            }
          }
        } else if kind == "touying-implicit-waypoint" {
          if not _waypoint-known(waypoints, child.body.value.label) {
            (
              repetitions,
              last-subslide,
              waypoints,
              decl-reps,
            ) = register-advancing-wp(
              child.body.value.label,
              repetitions,
              last-subslide,
              waypoints,
              decl-reps,
            )
          }
        }
      } else {
        // Cell body is not a direct metadata wrapper — recurse into it
        // to find any embedded waypoints/pauses.
        let body = child.at("body", default: none)
        if body != none {
          let inner = if utils.is-sequence(body) {
            body.children
          } else {
            (body,)
          }
          (
            repetitions,
            last-subslide,
            waypoints,
            start-overrides,
            decl-reps,
          ) = _collect-waypoints-impl(
            inner,
            repetitions,
            last-subslide,
            waypoints,
            start-overrides,
            decl-reps,
          )
        }
      }
    } else if type(child) == content {
      // Recurse into content with a body field
      let body = child.at("body", default: none)
      if body != none {
        let inner = if utils.is-sequence(body) {
          body.children
        } else {
          (body,)
        }
        (
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        ) = _collect-waypoints-impl(
          inner,
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        )
      }
      // Recurse into children (table, grid, stack, etc.)
      if child.has("children") {
        let ch = child.at("children", default: none)
        if ch != none and type(ch) == array {
          (
            repetitions,
            last-subslide,
            waypoints,
            start-overrides,
            decl-reps,
          ) = _collect-waypoints-impl(
            ch,
            repetitions,
            last-subslide,
            waypoints,
            start-overrides,
            decl-reps,
          )
        }
      }
    }
  }
  (repetitions, last-subslide, waypoints, start-overrides, decl-reps)
}



/// Collect all waypoint labels from slide bodies.
///
/// Returns a pair `(raw-waypoints, start-overrides)` where `raw-waypoints`
/// maps label strings to their raw subslide numbers and `start-overrides`
/// maps labels with explicit `start` to their start spec (int or label string).
///
/// - bodies (content): The content bodies to scan.
///
/// -> (dictionary, dictionary)
#let _collect-waypoints(..bodies) = {
  let (_, _, waypoints, start-overrides, decl-reps) = _collect-waypoints-impl(
    bodies.pos(),
    1,
    0,
    (:),
    (:),
    (:),
  )
  (waypoints, start-overrides, decl-reps)
}



// Find the first touying-reducer metadata dict inside content.
// Returns the metadata value dict, or none if not found.
#let _find-reducer-meta(c) = {
  if type(c) != content { return none }
  if (
    c.func() == metadata
      and type(c.value) == dictionary
      and c.value.at("kind", default: none) == "touying-reducer"
  ) {
    return c.value
  }
  if utils.is-sequence(c) {
    for child in c.children {
      let found = _find-reducer-meta(child)
      if found != none { return found }
    }
  }
  none
}


/// Parse touying equation content and extract animation repetitions
///
/// Processes equation content with pause and meanwhile markers, returning
/// the parsed equation and the total number of repetitions needed.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - eqt-metadata (content): The equation metadata to parse
///
/// -> (array, int)
#let _parse-touying-equation(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  eqt-metadata,
) = {
  let eqt = eqt-metadata.value
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  // get eqt body
  let it = eqt.body
  // if it is a function, then call it with self
  if type(it) == function {
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))
  // parse the content
  let result = ()
  let hidden-parts = ()
  let children = it
    .split(regex("(#meanwhile;?)|(meanwhile)"))
    .intersperse("touying-meanwhile")
    .map(s => s.split(regex("(#pause;?)|(pause)")).intersperse("touying-pause"))
    .flatten()
    .map(s => s.split(regex("(\\\\\\s)|(\\\\\\n)")).intersperse("\\\n"))
    .flatten()
    .map(s => s.split(regex("&")).intersperse("&"))
    .flatten()
  for child in children {
    if child == "touying-pause" {
      repetitions += 1
    } else if child == "touying-meanwhile" {
      // clear the hidden-parts when encounter #meanwhile
      if hidden-parts.len() != 0 {
        result.push("cover(" + hidden-parts.sum() + ")")
        hidden-parts = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the hidden-parts when encounter linebreak or parbreak
      if hidden-parts.len() != 0 {
        result.push("cover(" + hidden-parts.sum() + ")")
        hidden-parts = ()
      }
      result.push(child)
    } else {
      if repetitions <= index or not need-cover {
        result.push(child)
      } else {
        hidden-parts.push(child)
      }
    }
  }
  // clear the hidden-parts when end
  if hidden-parts.len() != 0 {
    result.push("cover(" + hidden-parts.sum() + ")")
    hidden-parts = ()
  }
  let equation = math.equation(
    block: eqt.block,
    numbering: eqt.numbering,
    supplement: eqt.supplement,
    eval(
      "$" + result.sum(default: "") + "$",
      scope: eqt.scope
        + (
          cover: (..args) => {
            let cover = eqt.scope.at("cover", default: cover)
            if args.pos().len() != 0 {
              cover(args.pos().first())
            }
          },
        ),
    ),
  )
  if (
    eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark>
  ) {
    equation = [#equation#eqt-metadata.label]
  }
  parsed-results.push(equation)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Parse touying mitex content and extract animation repetitions
///
/// Similar to _parse-touying-equation but for MiTeX equations.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - eqt-metadata (content): The mitex metadata to parse
///
/// -> (array, int)
#let _parse-touying-mitex(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  eqt-metadata,
) = {
  let eqt = eqt-metadata.value
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get eqt body
  let it = eqt.body
  // if it is a function, then call it with self
  if type(it) == function {
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))
  // parse the content
  let result = ()
  let hidden-parts = ()
  let children = it
    .split(regex("\\\\meanwhile"))
    .intersperse("touying-meanwhile")
    .map(s => s.split(regex("\\\\pause")).intersperse("touying-pause"))
    .flatten()
    .map(s => s.split(regex("(\\\\\\\\\s)|(\\\\\\\\\n)")).intersperse("\\\\\n"))
    .flatten()
    .map(s => s.split(regex("&")).intersperse("&"))
    .flatten()
  for child in children {
    if child == "touying-pause" {
      repetitions += 1
    } else if child == "touying-meanwhile" {
      // clear the hidden-parts when encounter #meanwhile
      if hidden-parts.len() != 0 {
        result.push("\\phantom{" + hidden-parts.sum() + "}")
        hidden-parts = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the hidden-parts when encounter linebreak or parbreak
      if hidden-parts.len() != 0 {
        result.push("\\phantom{" + hidden-parts.sum() + "}")
        hidden-parts = ()
      }
      result.push(child)
    } else {
      if repetitions <= index or not need-cover {
        result.push(child)
      } else {
        hidden-parts.push(child)
      }
    }
  }
  // clear the hidden-parts when end
  if hidden-parts.len() != 0 {
    result.push("\\phantom{" + hidden-parts.sum() + "}")
    hidden-parts = ()
  }
  let equation = (eqt.mitex)(
    block: eqt.block,
    numbering: eqt.numbering,
    supplement: eqt.supplement,
    result.sum(default: ""),
  )
  if (
    eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark>
  ) {
    equation = [#equation#eqt-metadata.label]
  }
  parsed-results.push(equation)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Parse touying raw content and extract animation repetitions
///
/// Processes raw code block content with pause and meanwhile markers, returning
/// the rendered raw block and the total number of repetitions needed.
///
/// A line acts as a pause or meanwhile marker when every meaningful character
/// on that line (letters, digits, CJK) spells exactly "pause" or "meanwhile".
/// This allows markers like `// pause`, `# pause`, or `#pause` while ignoring
/// lines like `pause = 1` or `def pause():`.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - raw-metadata (content): The raw metadata to parse
///
/// -> (array, int)
#let _parse-touying-raw(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  raw-metadata,
) = {
  let raw-data = raw-metadata.value
  // Pattern matching meaningful characters: letters, digits, and CJK Unified Ideographs
  let meaningful-chars-pattern = regex("[a-zA-Z0-9\u{4E00}-\u{9FFF}]+")
  let parsed-results = ()
  let repetitions = base
  let max-repetitions = repetitions
  let it = raw-data.body
  if type(it) == function {
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))

  let result-text = ""

  if raw-data.simple {
    // Simple mode: split directly on #pause; and #meanwhile; markers.
    // Markers may appear anywhere in the text (including inline), so we work
    // directly with text segments rather than splitting into lines first —
    // that would introduce spurious newlines when markers are inline.
    let text-parts = ()
    let parts = it
      .split(regex("#meanwhile;"))
      .intersperse("touying-meanwhile")
      .map(s => s.split(regex("#pause;")).intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      } else {
        if repetitions <= index or not need-cover {
          text-parts.push(part)
        } else if raw-data.fill-empty-lines {
          // Preserve line structure: keep newlines, erase all other characters
          text-parts.push(part.replace(regex("[^\n]+"), ""))
        }
      }
    }
    result-text = text-parts.join("")
  } else {
    // Normal mode: process line by line.
    // A line is a pause/meanwhile marker when its only meaningful characters
    // (letters, digits, CJK Unified Ideographs) spell exactly "pause" or "meanwhile"
    let result-lines = ()
    let lines = it.split("\n")
    for line in lines {
      let meaningful = line
        .matches(meaningful-chars-pattern)
        .map(m => m.text)
        .join("")
      if meaningful == "pause" {
        repetitions += 1
      } else if meaningful == "meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      } else if repetitions <= index or not need-cover {
        result-lines.push(line)
      } else if raw-data.fill-empty-lines {
        result-lines.push("")
      }
    }
    result-text = result-lines.join("\n")
  }
  let raw-block = raw(result-text, lang: raw-data.lang, block: raw-data.block)
  if (
    raw-metadata.has("label") and raw-metadata.label != <touying-temporary-mark>
  ) {
    raw-block = [#raw-block#raw-metadata.label]
  }
  parsed-results.push(raw-block)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Resolve a waypoint label or dictionary marker to a single integer subslide index.
/// Extracts the "beginning" (or "first") value from resolved waypoint dictionaries.
#let _resolve-waypoint-to-int(self, spec) = {
  let resolved = utils.resolve-waypoints(self, spec)
  if type(resolved) == int {
    resolved
  } else if type(resolved) == dictionary {
    resolved.at("beginning", default: resolved.at("first", default: 1))
  } else {
    panic("unexpected resolved waypoint type: " + repr(resolved))
  }
}


///
/// This is the core parsing function that handles all types of content including
/// animations, pauses, meanwhile markers, and various content types. It recursively
/// processes content and determines what should be visible on each subslide.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - show-delayed-wrapper (bool): Whether to show delayed wrapper content
/// - bodies (content): The content elements to parse
///
/// -> (array, int, int, int)
#let _parse-content-into-results-and-repetitions(
  self: none,
  need-cover: true,
  base: 1,
  base-last-subslide: 0,
  index: 1,
  show-delayed-wrapper: false,
  ..bodies,
) = {
  let labeled(func) = {
    return not (
      "repeat" in self
        and "subslide" in self
        and "label-only-on-last-subslide" in self
        and func in self.label-only-on-last-subslide
        and self.subslide != self.repeat
    )
  }
  // Helper function to parse child content and reconstruct
  // Returns a 5-tuple:
  //   - reconstructed-content: the reconstructed container content
  //   - max-repetitions: maximum repetitions found inside the content
  //   - next-last-subslide: maximum last-subslide of any fn-wrappers found (0 if none)
  //   - final-repetitions: repetitions count after processing all inner content
  //   - force-to-result: true when fn-wrappers were found inside a pause zone and the
  //       returned `reconstructed-content` was produced with proper inner covering;
  //       the caller MUST push this content directly to `result` (not `hidden-parts`).
  let parse-and-reconstruct(
    self,
    child,
    body-field,
    repetitions,
    last-subslide,
    index,
    need-cover,
    reconstruct-fn,
  ) = {
    let body-content = if body-field == "body-or-none" {
      child.at("body", default: none)
    } else {
      child.at(body-field)
    }
    let (
      conts,
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
      inner-has-fn-wrapper,
    ) = _parse-content-into-results-and-repetitions(
      self: self,
      need-cover: repetitions <= index,
      base: repetitions,
      base-last-subslide: last-subslide,
      index: index,
      body-content,
    )
    let cont = conts.first()
    // Two-pass: if fn-wrappers are present inside a pause zone, re-run the inner parse
    // with the outer need-cover so that fn-wrappers handle their own visibility and
    // non-fn-wrapper content is properly covered by the inner mechanism.
    let would-be-hidden = not (
      calc.min(repetitions, final-repetitions) <= index or not need-cover
    )
    if would-be-hidden and inner-has-fn-wrapper {
      let (
        conts2,
        inner-max-repetitions2,
        _,
        _,
        _,
      ) = _parse-content-into-results-and-repetitions(
        self: self,
        need-cover: need-cover,
        base: repetitions,
        base-last-subslide: last-subslide,
        index: index,
        body-content,
      )
      let cont2 = conts2.first()
      return (
        reconstruct-fn(child, cont2),
        inner-max-repetitions2,
        next-last-subslide,
        final-repetitions,
        true,
      )
    }
    return (
      reconstruct-fn(child, cont),
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
      false,
    )
  }
  // Content function sets for different handling categories
  let list-item-functions = (list.item, enum.item, align, link)
  let table-like-functions = (table, grid, stack)
  let reconstructable-functions = (
    pad,
    figure,
    quote,
    strong,
    emph,
    footnote,
    highlight,
    overline,
    underline,
    strike,
    smallcaps,
    sub,
    super,
    box,
    block,
    hide,
    move,
    scale,
    circle,
    ellipse,
    rect,
    square,
    table.cell,
    grid.cell,
    math.equation,
    heading,
  )
  let bodies = bodies.pos()
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // last-subslide by touying-fn-wrapper — inherit outer context so waypoints
  // placed after multi-subslide fn-wrappers fire correctly inside sub-sequences.
  let last-subslide = base-last-subslide
  // Whether any touying-fn-wrapper was found in this parse (directly or via
  // recursive calls).  Used by the two-pass escape hatch so that fn-wrappers
  // inside a pause zone can handle their own visibility.
  let has-fn-wrapper = false
  // get cover function from self
  let cover = self.methods.cover.with(self: self)

  // Main parsing loop: process each content item and handle animations
  for item in bodies {
    let it = item
    // Special handling for table/grid cells containing pause/meanwhile/waypoint markers
    // This is a workaround for syntax like #table([A], pause, [B])
    // Waypoints and implicit waypoints are also stripped so they don't occupy a cell slot.
    if type(it) == content and it.func() in (table.cell, grid.cell) {
      if (
        type(it.body) == content
          and it.body.func() == metadata
          and type(it.body.value) == dictionary
      ) {
        let kind = it.body.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if it.body.value.relative {
            repetitions = calc.max(repetitions, last-subslide) + it.body.value.n
          } else {
            // absolute jump
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = it.body.value.n
            last-subslide = 0
          }
          continue
        } else if kind == "touying-waypoint" {
          let wp = self.at("waypoints", default: (:))
          let lbl = it.body.value.label
          let wp-start = it.body.value.at("start", default: auto)
          if wp-start != auto and lbl in wp {
            // Explicit start: absolute jump to the resolved position.
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = wp.at(lbl).first
            last-subslide = 0
          } else if it.body.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if (
              first == repetitions + 1
                or (first == last-subslide + 1 and first > repetitions)
            ) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          continue
        } else if kind == "touying-implicit-waypoint" {
          let wp = self.at("waypoints", default: (:))
          let lbl = it.body.value.label
          if lbl in wp {
            let first = wp.at(lbl).first
            if (
              first == repetitions + 1
                or (first == last-subslide + 1 and first > repetitions)
            ) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          continue
        }
      }
    }
    // if it is a function, then call it with self
    if type(it) == function {
      // subslide index
      it = it(self)
    }
    // parse the content
    let result = ()
    let hidden-parts = ()

    // Helper: is this content element a list/enum/terms item?
    let _is-list-item(it) = (
      type(it) == content
        and (
          it.func() == list.item
            or it.func() == enum.item
            or it.func() == terms.item
        )
    )

    /// Flush the hidden-parts buffer as covered content.  `last-result` is the
    /// current visible result array at the flush point.  We only wrap in
    /// `block(spacing: par.leading)` when the last visible element AND the first
    /// hidden element are both list/enum/terms items — i.e. a list interrupted
    /// by `#pause`.  In all other cases (text→list, list→text, text→text) the
    /// default paragraph spacing is correct.
    let cover-hidden(cover-fn, items, last-result) = {
      // First non-space hidden element
      let first-pos = items.position(item => not utils.is-space(item))
      let first-is-list = (
        first-pos != none and _is-list-item(items.at(first-pos))
      )

      // Last non-space visible element (walk result backwards).
      // We only skip space nodes — parbreaks and linebreaks are meaningful
      // separators.  A parbreak between the last visible list item and the
      // hidden zone means the user broke the implicit list with a blank line,
      // so paragraph spacing should be used instead of list spacing.
      let last-is-list = {
        let found = false
        for i in range(last-result.len()) {
          let item = last-result.at(last-result.len() - 1 - i)
          if utils.is-space(item) {
            // skip space nodes only
          } else {
            found = _is-list-item(item)
            break
          }
        }
        found
      }
      let spacing-is-auto(it) = {
        if it.func() == list.item {
          list.spacing == auto
        } else if it.func() == enum.item {
          enum.spacing == auto
        } else if it.func() == terms.item {
          terms.spacing == auto
        } else {
          false
        }
      }
      let covered = cover-fn(items.sum())
      //decrease below spacing for rect cover functions
      // if type(cover-fn) == function and (
      //   cover-fn==utils.cover-with-rect or
      //   cover-fn==utils.semi-transparent-cover
      // ){
      //   covered // does not fix it, but does not hurt: problem stems from box itself causing later content to be shifted? idk
      // }else
      if first-is-list and last-is-list {
        let first-item = items.at(first-pos)
        // construct a block around the covered content that corrects spacing. looks for auto
        context block(
          spacing: if spacing-is-auto(first-item) {
            // would yield `auto` which is a par.spacing for the block.
            if self.at("nontight-list-enum-and-terms", default: true) {
              //cannot set list thightness via set rule somehow. if user uses magic.nontight locally we can't detect that, so we just assume he only uses the config. thus this might break.
              par.spacing
            } else {
              par.leading
            }
          } else {
            if first-item.func() == list.item {
              list.spacing
            } else if first-item.func() == enum.item {
              enum.spacing
            } else if first-item.func() == terms.item {
              terms.spacing
            } else {
              par.spacing
            }
          },
          covered,
        )
      } else {
        covered
      }
    }

    // Flatten sequences and handle each child element
    let children = if utils.is-sequence(it) {
      it.children
    } else {
      (it,)
    }

    // Process each child element for animation markers and content types
    for child in children {
      if (
        type(child) == content
          and child.func() == metadata
          and type(child.value) == dictionary
      ) {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            // Snap past any preceding fn-wrapper range before applying the
            // relative jump, so that a #pause after e.g. item-by-item lands
            // after the full animation, not after its first subslide.
            repetitions = calc.max(repetitions, last-subslide) + child.value.n
            // Track the peak repetitions so that a subsequent negative jump doesn't
            // cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
            // If we jumped back into the visible zone, flush hidden-parts in order
            // (so they appear before subsequent visible content, not after it)
            if hidden-parts.len() != 0 and repetitions <= index {
              result.push(cover-hidden(cover, hidden-parts, result))
              hidden-parts = ()
            }
          } else {
            // absolute: reveal all hidden content then jump to target subslide
            if hidden-parts.len() != 0 {
              result.push(cover-hidden(cover, hidden-parts, result))
              hidden-parts = ()
            }
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = child.value.n
            last-subslide = 0
          }
        } else if kind in ("touying-equation", "touying-mitex", "touying-raw") {
          // Handle animated equation/mitex/raw blocks with pause/meanwhile markers
          let parse-fn = if kind == "touying-equation" {
            _parse-touying-equation
          } else if kind == "touying-mitex" {
            _parse-touying-mitex
          } else {
            _parse-touying-raw
          }
          let (conts, nextrepetitions) = parse-fn(
            self: self,
            need-cover: repetitions <= index,
            base: repetitions,
            index: index,
            child,
          )
          let cont = conts.first()
          if repetitions <= index or not need-cover {
            result.push(cont)
          } else {
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-reducer" {
          // Handle external package reducers (CeTZ, Fletcher) with animations
          let (conts, nextrepetitions) = _parse-touying-reducer(
            self: self,
            base: repetitions,
            index: index,
            child.value,
          )
          let cont = conts.first()
          if repetitions <= index or not need-cover {
            result.push(cont)
          } else {
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-render" {
          // Render inline content at a specific subslide.
          // In slide mode, default (auto) renders at the current slide index.
          let inline-content = child.value.content
          let subslide-spec = child.value.subslide
          let use-slide-context = child.value.at("base", default: auto) == auto
          let render-base = if use-slide-context { repetitions } else {
            child.value.base
          }
          // Compute render context (inlined from _prepare-render-context)
          let reducer-data = _find-reducer-meta(inline-content)
          let (raw-wp, so, dr) = _collect-waypoints(inline-content)
          let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
          let content-mrr = if reducer-data != none {
            let (_, mrr) = _parse-touying-reducer(
              self: self + (waypoints: (:), subslide: 9999),
              base: render-base,
              index: 9999,
              reducer-data,
            )
            mrr
          } else {
            let (_, mrr, _, _, _) = _parse-content-into-results-and-repetitions(
              self: self + (waypoints: (:), subslide: 9999),
              base: render-base,
              index: 9999,
              inline-content,
            )
            mrr
          }
          let content-repeat = calc.max(content-mrr, ..resolved-wp.values(), 1)
          let content-cwp = _compute-waypoint-ranges(
            resolved-wp,
            content-repeat,
            so,
            dr,
          )
          // When using slide context (auto), use the slide's waypoints
          // for target resolution; otherwise use the content's own waypoints.
          // The repeat bound is always the content's own repeat count
          // (`content-repeat`, already computed with `render-base` baked in
          // via `_parse-touying-reducer`/`_parse-content-into-results-and-repetitions`
          // above) — `self.repeat` is the *enclosing slide's* pause count,
          // which is unrelated to how many stages this rendered content has.
          let cwp = if use-slide-context {
            self.at("waypoints", default: (:))
          } else {
            content-cwp
          }
          let rp = content-repeat
          let target = if subslide-spec == auto { index } else {
            let spec = subslide-spec
            let wp-self = self + (waypoints: cwp)
            if (
              type(spec) == label
                or (
                  type(spec) == dictionary
                    and spec.at("kind", default: "") in waypoint-kinds
                )
            ) {
              _resolve-waypoint-to-int(wp-self, spec)
            } else if type(spec) == int {
              // `rp` is the absolute final counter value (it already
              // includes `render-base`), so convert it to a plain stage
              // count before resolving negative indices relative to `base`.
              utils.resolve-negative-subslides(
                rp - render-base + 1,
                spec,
                base: render-base,
              )
            } else { rp }
          }
          // Render at target (inlined from _render-at-subslide)
          let render-self = self + (waypoints: cwp, subslide: target)
          let cont = if reducer-data != none {
            let (r, _) = _parse-touying-reducer(
              self: render-self,
              base: render-base,
              index: target,
              reducer-data,
            )
            r.sum(default: none)
          } else {
            let (
              conts,
              _,
              _,
              _,
              _,
            ) = _parse-content-into-results-and-repetitions(
              self: render-self,
              base: render-base,
              index: target,
              inline-content,
            )
            conts.sum(default: none)
          }
          if cont != none {
            result.push(cont)
          }
          // When subslide: auto, this content's animation contributes to the
          // outer slide's repetition count (same as an inlined reducer/block).
          if subslide-spec == auto {
            repetitions = content-mrr
          }
        } else if kind == "touying-fn-wrapper" {
          // Handle function wrappers (uncover, only, alternatives, etc.)
          // These always escape the pause zone: they handle their own subslide
          // visibility internally, so they must never be pushed to hidden-parts.
          has-fn-wrapper = true
          let nextrepetitions = repetitions
          let extra-args = (:)
          if child.value.last-subslide != none {
            if type(child.value.last-subslide) == function {
              let (callback-last-subslide, callback-extra-args) = (
                child.value.last-subslide
              )(
                repetitions,
              )
              // Use calc.max to prevent callback from decreasing last-subslide
              // (mirrors the non-callback else-branch)
              last-subslide = calc.max(last-subslide, callback-last-subslide)
              extra-args = callback-extra-args
            } else {
              last-subslide = calc.max(last-subslide, child.value.last-subslide)
            }
          }
          //check child.value.args for touying-fn-wrapper-raw. may only be in content, which always is positional
          let pos-args = child
            .value
            .args
            .pos()
            .map(c => {
              if (
                type(c) == content
                  and c.func() == metadata
                  and type(c.value) == dictionary
                  and c.value.at("kind", default: none)
                    == "touying-fn-wrapper-raw"
              ) {
                (c.value.fn)(
                  self: self,
                  ..c.value.args,
                )
              } else {
                c
              }
            })

          // Flush hidden-parts before calling the fn-wrapper, so it renders in
          // the correct order relative to subsequent visible content (fn-wrappers
          // always render in-place and never go through hidden-parts themselves).
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          result.push((child.value.fn)(
            self: self,
            ..pos-args,
            ..child.value.args.named(),
            ..extra-args,
          ))
          repetitions = nextrepetitions
        } else if kind == "touying-fn-wrapper-raw" {
          // Handle raw function wrappers (e.g., #alert)
          if repetitions <= index or not need-cover {
            result.push((child.value.fn)(
              self: self,
              ..child.value.args,
            ))
          } else {
            hidden-parts.push((child.value.fn)(
              self: self,
              ..child.value.args,
            ))
          }
        } else if kind == "touying-speaker-note" {
          // Handle speaker notes with optional #pause markers inside the note body.
          // Speaker notes always escape the pause zone (like fn-wrappers): they emit
          // only side effects (state updates, pdfpc metadata) and produce no visible content.
          let outer-rep = repetitions // pause count at this position in the outer slide

          // Inner subslide index: how far into the note's own pauses we advance.
          // If the outer slide is at repetition outer-rep and we're rendering subslide index,
          // the note's inner subslide is (index - outer-rep + 1), clamped to >= 1.
          let inner-index = calc.max(1, index - outer-rep + 1)

          // Use _parse-content-into-results-and-repetitions to handle nested pauses
          // (e.g. #pause inside a list item). Override cover to omit hidden content
          // entirely (notes don't need visual placeholders for covered text).
          let note-self = utils.merge-dicts(
            self,
            (methods: (cover: (self: none, body) => [])),
          )
          let (
            note-conts,
            note-max-rep,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: note-self,
            need-cover: true,
            base: 1,
            index: inner-index,
            child.value.note,
          )
          let note-cont = note-conts.first()

          // Account for subslides needed by inner pauses in the note body.
          max-repetitions = calc.max(
            max-repetitions,
            outer-rep + note-max-rep - 1,
          )

          // Determine the effective outer subslide filter.
          let effective-subslide = if child.value.subslide == auto {
            str(outer-rep) + "-"
          } else {
            child.value.subslide
          }

          // Always push to result (never hidden-parts): produces no visible content.
          result.push(utils.speaker-note(
            self: self,
            mode: child.value.mode,
            setting: child.value.setting,
            subslide: effective-subslide,
            note-cont,
          ))
        } else if kind == "touying-waypoint" {
          let wp = self.at("waypoints", default: (:))
          let lbl = child.value.label
          let wp-start = child.value.at("start", default: auto)
          if wp-start != auto and lbl in wp {
            // Explicit start: absolute jump to the resolved position.
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = wp.at(lbl).first
            last-subslide = 0
          } else if child.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if (
              first == repetitions + 1
                or (first == last-subslide + 1 and first > repetitions)
            ) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output.
        } else if kind == "touying-implicit-waypoint" {
          // Implicit waypoint: advance repetitions if this is the defining occurrence.
          // Fires on the standard sequential trigger (first == repetitions+1) OR
          // when a preceding fn-wrapper pushed last-subslide forward and this
          // waypoint sits immediately after it (first == last-subslide+1).
          let wp = self.at("waypoints", default: (:))
          let lbl = child.value.label
          if lbl in wp {
            let first = wp.at(lbl).first
            if (
              first == repetitions + 1
                or (first == last-subslide + 1 and first > repetitions)
            ) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output.
        } else if kind == "touying-block-recall" {
          panic(
            "touying-block-recall can only be used inside document-text or document-only blocks. "
              + "Use touying-render instead to render animated blocks at specific subslides.",
          )
        } else if kind == "touying-delayed-wrapper" {
          if show-delayed-wrapper {
            if repetitions <= index or not need-cover {
              result.push(child.value.body)
            } else {
              hidden-parts.push(child.value.body)
            }
          }
        } else {
          if repetitions <= index or not need-cover {
            result.push(child)
          } else {
            hidden-parts.push(child)
          }
        }
      } else if child == linebreak() or child == parbreak() {
        // clear the hidden-parts when encounter linebreak or parbreak
        if hidden-parts.len() != 0 {
          result.push(cover-hidden(cover, hidden-parts, result))
          hidden-parts = ()
        }
        result.push(child)
      } else if utils.is-sequence(child) {
        // handle the sequence
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        // Two-pass: if fn-wrappers are present and sequence would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
            index: index,
            child,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the sequence
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(cont)
        } else {
          hidden-parts.push(cont)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if utils.is-styled(child) {
        // handle styled
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "child",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, cont) => utils.typst-builtin-styled(cont, child.styles),
        )
        // Propagate meanwhile effect from inside the styled element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or force-to-result
      } else if (
        type(child) == content and child.func() in list-item-functions
      ) {
        // handle the list item
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "body",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, cont) => utils.reconstruct(
            child,
            labeled: labeled(child.func()),
            cont,
          ),
        )
        // Propagate meanwhile effect from inside the list item
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or force-to-result
      } else if (
        type(child) == content and child.func() in table-like-functions
      ) {
        // handle the table-like
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          ..child.children,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        // Two-pass: if fn-wrappers are present and container would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (conts, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
            index: index,
            ..child.children,
          )
          (conts2, inner-max-repetitions2)
        } else {
          (conts, inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the table/grid/stack
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        let reconstructed-table = utils.reconstruct-table-like(
          child,
          labeled: labeled(child.func()),
          conts,
        )
        if (
          would-be-hidden and inner-has-fn-wrapper
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed-table)
        } else {
          hidden-parts.push(reconstructed-table)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if (
        type(child) == content and child.func() in reconstructable-functions
      ) {
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "body-or-none",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, cont) => utils.reconstruct(
            named: true,
            labeled: labeled(child.func()),
            child,
            cont,
          ),
        )
        // Propagate meanwhile effect from inside the reconstructable element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or force-to-result
      } else if type(child) == content and child.func() == terms.item {
        // handle the terms item
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "description",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, cont) => terms.item(child.term, cont),
        )
        // Propagate meanwhile effect from inside the terms item
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or force-to-result
      } else if type(child) == content and child.func() == columns {
        // handle columns
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        let args = if child.has("gutter") {
          (gutter: child.gutter)
        }
        let count = if child.has("count") {
          child.count
        } else {
          2
        }
        // Two-pass: if fn-wrappers are present and columns would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the columns
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(columns(count, ..args, cont))
        } else {
          hidden-parts.push(columns(count, ..args, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == place {
        // handle place
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        let fields = child.fields()
        let _ = fields.remove("alignment", default: none)
        let _ = fields.remove("body", default: none)
        let alignment = if child.has("alignment") {
          child.alignment
        } else {
          start
        }
        // Two-pass: if fn-wrappers are present and place would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the place
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(place(alignment, ..fields, cont))
        } else {
          hidden-parts.push(place(alignment, ..fields, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == rotate {
        // handle rotate
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        let fields = child.fields()
        let _ = fields.remove("angle", default: none)
        let _ = fields.remove("body", default: none)
        let angle = if child.has("angle") {
          child.angle
        } else {
          0deg
        }
        // Two-pass: if fn-wrappers are present and rotate would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the rotate
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(rotate(angle, ..fields, cont))
        } else {
          hidden-parts.push(rotate(angle, ..fields, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else {
        if repetitions <= index or not need-cover {
          result.push(child)
        } else {
          hidden-parts.push(child)
        }
      }
    }
    // clear the hidden-parts when end
    if hidden-parts.len() != 0 {
      result.push(cover-hidden(cover, hidden-parts, result))
      hidden-parts = ()
    }
    parsed-results.push(result.sum(default: []))
  }
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (
    parsed-results,
    max-repetitions,
    last-subslide,
    repetitions,
    has-fn-wrapper,
  )
}


/// Prepare the rendering context for a touying-render node.
/// Computes waypoints, max repetitions, and reducer metadata from inline content.
///
/// Returns: `(reducer-data, cwp, repeat, max-rep-raw)`
/// - `reducer-data`: reducer metadata dict if content is a reducer, else `none`
/// - `cwp`: computed waypoint ranges
/// - `repeat`: max repetitions (including waypoints)
/// - `max-rep-raw`: raw max repetitions from the content's animation (before waypoints)
#let _prepare-render-context(self, inline-content, render-base) = {
  let reducer-data = _find-reducer-meta(inline-content)
  let (raw-wp, so, dr) = _collect-waypoints(inline-content)
  let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
  let max-rep-raw = if reducer-data != none {
    let (_, mrr) = _parse-touying-reducer(
      self: self + (waypoints: (:), subslide: 9999),
      base: render-base,
      index: 9999,
      reducer-data,
    )
    mrr
  } else {
    let (_, mrr, _, _, _) = _parse-content-into-results-and-repetitions(
      self: self + (waypoints: (:), subslide: 9999),
      base: render-base,
      index: 9999,
      inline-content,
    )
    mrr
  }
  let repeat = calc.max(max-rep-raw, ..resolved-wp.values(), 1)
  let cwp = _compute-waypoint-ranges(resolved-wp, repeat, so, dr)
  (reducer-data, cwp, repeat, max-rep-raw)
}


/// Render inline content at a specific target subslide.
///
/// Returns: rendered content (or `none`)
#let _render-at-subslide(
  self,
  inline-content,
  reducer-data,
  cwp,
  render-base,
  target,
) = {
  let render-self = self + (waypoints: cwp, subslide: target)
  if reducer-data != none {
    let (r, _) = _parse-touying-reducer(
      self: render-self,
      base: render-base,
      index: target,
      reducer-data,
    )
    r.sum(default: none)
  } else {
    let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
      self: render-self,
      base: render-base,
      index: target,
      inline-content,
    )
    conts.sum(default: none)
  }
}

