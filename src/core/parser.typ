#import "../utils.typ"
#import "../extern.typ"
#import "tree.typ"
#import "waypoints.typ": (
  _compute-waypoint-ranges, _resolve-waypoint-forest, _waypoint-known,
  waypoint-kinds,
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
    if type(arg) == content and tree.is-sequence(arg) {
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
          repetitions += child.value.n
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
          if first == repetitions + 1 {
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
          if first == repetitions + 1 {
            repetitions = first
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
        }
      } else if kind == "touying-fn-wrapper" {
        // Handle function wrappers (uncover, only, alternatives, etc.)
        // These always escape the pause zone: they handle their own visibility.
        let extra-args = (:)
        if child.value.last-subslide != none {
          let resolved = if type(child.value.last-subslide) == function {
            let (callback-last-subslide, callback-extra-args) = (
              child.value.last-subslide
            )(
              repetitions,
            )
            extra-args = callback-extra-args
            callback-last-subslide
          } else {
            child.value.last-subslide
          }
          last-subslide = calc.max(last-subslide, resolved)
          if child.value.at("advances-flow", default: false) {
            repetitions = calc.max(repetitions, resolved)
            max-repetitions = calc.max(max-repetitions, repetitions)
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
            type(fn-result) == content and tree.is-sequence(fn-result)
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
      if type(arg) == content and tree.is-sequence(arg) {
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
            repetitions += child.value.n
            max-repetitions = calc.max(max-repetitions, repetitions)
          } else {
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = child.value.n
            last-subslide = 0
          }
        } else if k == "touying-waypoint" {
          if child.value.at("advance", default: true) {
            repetitions += 1
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
        } else if k == "touying-implicit-waypoint" {
          repetitions += 1
          max-repetitions = calc.max(max-repetitions, repetitions)
        } else if k == "touying-fn-wrapper" {
          let ls = child.value.at("last-subslide", default: none)
          let resolved = if type(ls) == function {
            ls(repetitions).first()
          } else if type(ls) == int { ls } else { none }
          if resolved != none {
            last-subslide = calc.max(last-subslide, resolved)
            if child.value.at("advances-flow", default: false) {
              repetitions = calc.max(repetitions, resolved)
              max-repetitions = calc.max(max-repetitions, repetitions)
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
/// (the pause cursor at that point).
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
  // Helper: register a new advancing waypoint at the correct position, one
  // step past the pause flow. A flow-advancing fn-wrapper (item-by-item) has
  // already moved `repetitions` to the end of its own range by the time we
  // get here, so a waypoint after one still lands after its full animation;
  // a wrapper that only animates its own body (uncover/only) leaves the flow
  // where it was, and the waypoint lands one step past *that*.
  let register-advancing-wp(
    lbl,
    repetitions,
    last-subslide,
    waypoints,
    decl-reps,
  ) = {
    decl-reps.insert(lbl, repetitions)
    let pos = repetitions + 1
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
    decl-reps.insert(lbl, repetitions)
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
    if tree.is-sequence(child) {
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
          repetitions += child.value.n
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
        let inner = if tree.is-sequence(child.value.body) {
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
          if type(arg) == content and tree.is-sequence(arg) {
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
                inner-rep += inner-child.value.n
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
                  decl-reps.insert(inner-child.value.label, inner-rep)
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
              let resolved = if type(ls) == function {
                ls(inner-rep).first()
              } else if type(ls) == int { ls } else { none }
              if resolved != none {
                inner-ls = calc.max(inner-ls, resolved)
                if inner-child.value.at("advances-flow", default: false) {
                  inner-rep = calc.max(inner-rep, resolved)
                  inner-max = calc.max(inner-max, inner-rep)
                }
              }
            }
          }
        }
        repetitions = calc.max(inner-max, inner-rep)
        last-subslide = calc.max(last-subslide, inner-ls)
      } else if kind == "touying-fn-wrapper" {
        // fn-wrappers can span multiple subslides via their last-subslide
        // field. That always grows the slide's total (last-subslide), but
        // only a flow-advancing one (item-by-item) also moves the pause
        // cursor, so that a following pause or waypoint lands after its full
        // animation range rather than one step past where it started.
        let ls = child.value.at("last-subslide", default: none)
        let resolved = if type(ls) == function {
          ls(repetitions).first()
        } else if type(ls) == int { ls } else { none }
        if resolved != none {
          last-subslide = calc.max(last-subslide, resolved)
          if child.value.at("advances-flow", default: false) {
            repetitions = calc.max(repetitions, resolved)
          }
        }
      }
    } else if tree.is-styled(child) {
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
            repetitions += child.body.value.n
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
          let inner = if tree.is-sequence(body) {
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
        let inner = if tree.is-sequence(body) {
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
  if tree.is-sequence(c) {
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


/// Resolve "passive" marks anywhere inside a content tree: a
/// `touying-fn-wrapper-raw` (e.g. `#alert`) is called in place, a
/// `touying-slide-recaller` is handed to `resolve-recall`. Passive marks have no
/// multi-subslide behaviour of their own, so they can be resolved before the
/// surrounding wrapper's visibility logic runs.
///
/// Recursive through a raw wrapper's own positional arguments, so a raw wrapper
/// nested inside another one is resolved too - `#uncover[#alert[a #alert[b]]]`
/// behaves like `#uncover[#alert[a]]`.
#let _resolve-passive-marks(
  body,
  self,
  resolve-recall,
) = tree.resolve-marks(
  body,
  ("touying-fn-wrapper-raw", "touying-slide-recaller"),
  v => if v.kind == "touying-fn-wrapper-raw" {
    (v.fn)(
      self: self,
      ..v.args.pos().map(c => _resolve-passive-marks(c, self, resolve-recall)),
      ..v.args.named(),
    )
  } else {
    resolve-recall(v)
  },
)

/// Resolve a waypoint label or dictionary marker to a single integer subslide index.
/// Extracts the "beginning" (or "first") value from resolved waypoint dictionaries.
/// Whether a `<touying:..>` label excludes this content from the current output
/// mode. Lives here rather than in slides.typ or article.typ because both the
/// slide splitter and the article renderer have to honour it, and article.typ
/// cannot import slides.typ (slides.typ already imports article.typ).
///
/// - self (dictionary): The presentation context.
///
/// - lbl (str, none): The label as a string, e.g. `"touying:handout-article"`.
///
/// -> bool
#let check-current-mode-skip(self, lbl) = {
  if lbl == none or not lbl.starts-with("touying:") { return false }
  let parts = lbl.slice("touying:".len()).split("-")
  // `touying:never` excludes the content from every output mode. It is the
  // empty mode list, so unlike presentation / handout / article -- which can
  // hold at the same time and therefore combine -- it does not compose.
  // Anything hyphenated onto it is not a valid label and filters nothing.
  if "never" in parts { return parts.len() == 1 }
  // Labels like touying:hidden / touying:skip carry no mode intent.
  let has-mode-keyword = (
    "presentation" in parts
      or "handout" in parts
      or "slides" in parts
      or "article" in parts
  )
  if not has-mode-keyword { return false }
  let in-presentation = "presentation" in parts and not self.handout
  let in-handout = "handout" in parts and self.handout
  let in-slides = (
    ("slides" in parts or in-presentation or in-handout)
      and not self.at("article-mode", default: false)
  )
  let in-article = (
    "article" in parts and self.at("article-mode", default: false)
  )
  not in-slides and not in-article
}

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

/// Every subslide index in `[lo, hi]` that `utils.check-visible` accepts
/// `spec` for. `check-visible` already understands every dict/string shape
/// `subslides:` can resolve to (`(beginning:, until:)`, `(kind: "not",
/// inner:)`, `"2-4"`, `"!2-4"`, ...), so this is the one shared primitive
/// both waypoint- and string-based member resolution below build on.
///
/// -> array (sorted, ascending)
#let _members-in-range(spec, lo, hi) = (
  range(lo, hi + 1).filter(idx => utils.check-visible(idx, spec))
)

/// Resolve a waypoint label or dictionary marker to the full, sorted set of
/// subslide indices it captures — unlike `_resolve-waypoint-to-int`, which
/// collapses a range down to its first ("beginning") value alone. A
/// single-subslide marker (`get-first`, `get-last`, ...) still comes back
/// as a one-element list, so callers never need to special-case cardinality.
///
/// - self (dictionary): carries the `waypoints` map `spec` is resolved against.
/// - spec (label, dictionary): the waypoint reference to resolve.
/// - bound (int): the local `1..bound` range used to enumerate the members
///   of a negated (`not-wp`) marker, whose own range is unbounded above.
///
/// -> array (sorted, ascending, non-empty)
#let _resolve-waypoint-to-members(self, spec, bound) = {
  let resolved = utils.resolve-waypoints(self, spec)
  if type(resolved) == int {
    (resolved,)
  } else {
    _members-in-range(resolved, 1, bound)
  }
}

/// Resolve a string `subslides:` spec (`"2-4"`, `"!2-4"`, ...) to the
/// sorted, ascending list of absolute subslide indices it captures within
/// `[lo, hi]`.
///
/// Deliberately does not support `only`/`effect`'s `"h"` (here) marker:
/// `"h"` there resolves against the *surrounding* flow's own live counter,
/// but every plain number in a `subslides:` spec already addresses
/// `body`'s own *local* counter — mixing the two within one string would
/// silently blend two different numbering spaces into one spec. `base:`
/// already exists for deliberately relating the two counters; conflating
/// them through `"h"` as well isn't worth the confusion.
///
/// -> array (sorted, ascending, non-empty)
#let _resolve-string-to-members(spec, lo, hi) = {
  let members = _members-in-range(spec, lo, hi)
  assert(
    members.len() > 0,
    message: "touying-render: subslides: "
      + repr(spec)
      + " matches no subslide in range "
      + str(lo)
      + ".."
      + str(hi)
      + ".",
  )
  members
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
  // Determine the "real" recall-relevant label for `child`, if any, and —
  // only on the slide's own last subslide, to avoid attaching the same
  // real label more than once across multiple rendered pages — emit an
  // invisible breadcrumb carrying the raw, pre-parse content under a label
  // derived from the original, if that content has more than one subslide
  // of its own. `touying-recall`'s fallback (see `_build-native-recall`)
  // looks this breadcrumb label up when an explicit subslide is requested;
  // the original label keeps pointing at the original element, completely
  // unchanged, for the default (auto/none) case.
  let maybe-build-recall-breadcrumb(child) = {
    // A touying-reducer stores its label inside the metadata dict (its own
    // attached label is the internal <touying-temporary-mark>, unaffected);
    // anything else uses its own directly-attached label.
    let real-label = if tree.is-kind(child, "touying-reducer") {
      child.value.at("label", default: none)
    } else if (
      type(child) == content
        and child.has("label")
        and child.label != <touying-temporary-mark>
    ) {
      child.label
    } else {
      none
    }
    if (
      real-label == none
        or self.at("subslide", default: none)
          != self.at("repeat", default: none)
    ) {
      return none
    }
    // Probe this child's own standalone repeat count (inlined from
    // _prepare-render-context — can't call it directly, it's defined later
    // in this file and itself depends on this function).
    let probe-reducer-data = _find-reducer-meta(child)
    let (raw-wp, so, dr) = _collect-waypoints(child)
    let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
    let max-rep-raw = if probe-reducer-data != none {
      let (_, mrr) = _parse-touying-reducer(
        self: self + (waypoints: (:), subslide: 9999),
        base: 1,
        index: 9999,
        probe-reducer-data,
      )
      mrr
    } else {
      let (_, mrr, _, _, _) = _parse-content-into-results-and-repetitions(
        self: self + (waypoints: (:), subslide: 9999),
        base: 1,
        index: 9999,
        child,
      )
      mrr
    }
    let own-repeat = calc.max(max-rep-raw, ..resolved-wp.values(), 1)
    if own-repeat <= 1 { return none }
    let breadcrumb-label = label(str(real-label) + ":touying-recall-breadcrumb")
    [#metadata((
        kind: "touying-recall-breadcrumb",
        content: child,
      ))#breadcrumb-label]
  }
  // Resolve touying-recall's fallback (non-whole-slide) target: a labeled
  // touying-reducer, or any other labeled content with its own subslide
  // dimension. Shared by the bare "touying-slide-recaller" dispatch below
  // and by touying-fn-wrapper's pre-processing step, so a fallback recall
  // can be nested inside #uncover[...]/#only[...]/#alternatives[...] and
  // gated by their own visibility logic instead — a fallback recall never
  // has multi-subslide behavior of its own to gate, unlike touying-render,
  // so it composes the same way #alert (touying-fn-wrapper-raw) already
  // does. Inlined here (not a top-level function) for the same reason
  // _build-native-recall/_prepare-render-context/_render-at-subslide can't
  // be called from inside this function's own body: they're defined later
  // in this file and themselves depend on
  // _parse-content-into-results-and-repetitions.
  let resolve-recall-fallback(self, raw-label, subslides, base) = {
    if type(raw-label) != label {
      panic(
        "touying-recall: a native label (e.g. <my-label>) is required "
          + "to recall a labeled reducer or other content from inside "
          + "a slide body — a string label can only target a "
          + "registered whole-slide recall at the top level of the document.",
      )
    }
    let recall-subslide = if subslides == none { auto } else { subslides }
    let recall-base = base
    if (
      recall-subslide != auto
        and type(recall-subslide) != int
        and type(recall-subslide) != label
        and not (
          type(recall-subslide) == dictionary
            and recall-subslide.at("kind", default: "") in waypoint-kinds
        )
    ) {
      panic(
        "touying-recall: subslides: "
          + repr(recall-subslide)
          + " is not supported outside a whole-slide target — only "
          + "auto/none, an int subslide number, or a waypoint label/marker "
          + "are supported here.",
      )
    }
    // Recalling a whole-slide target has no effect in article mode
    // (see article.typ's article-whole-slide-labels) — warn and
    // produce nothing rather than silently falling through to the
    // generic recall below, which would recall just a fragment
    // (e.g. a bare heading) of what the user probably meant as a
    // whole slide.
    let whole-slide-labels = self.at(
      "article-whole-slide-labels",
      default: (),
    )
    if (
      self.at("article-mode", default: false)
        and raw-label in whole-slide-labels
    ) {
      extern.warning(
        "touying-recall: label "
          + repr(raw-label)
          + " refers to a whole-slide recall target, which has no "
          + "effect in article mode. Wrap this call in "
          + "#slides-only[...] to suppress this warning once you've "
          + "confirmed that's what you want.",
      )
      return none
    }
    context {
      // Always check the breadcrumb first, regardless of subslide:
      // a touying-reducer's own real label is never itself attached
      // to anything (it only lives inside the metadata dict), so
      // "auto" still needs the breadcrumb's raw content to render
      // anything for a reducer, not just to pick a specific stage.
      let breadcrumb-label = label(
        str(raw-label) + ":touying-recall-breadcrumb",
      )
      let breadcrumb-found = query(breadcrumb-label)
      if breadcrumb-found.len() > 0 {
        let raw-content = breadcrumb-found.first().value.content
        let minimal-self = (
          methods: (cover: utils.method-wrapper(hide)),
          waypoints: (:),
          subslide: 1,
        )
        let render-base = if recall-base == auto { 1 } else {
          recall-base
        }
        // Inlined from _prepare-render-context/_render-at-subslide
        // (see this function's own doc comment for why they can't be
        // called directly).
        let reducer-data = _find-reducer-meta(raw-content)
        let (raw-wp, so, dr) = _collect-waypoints(raw-content)
        let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
        let max-rep-raw = if reducer-data != none {
          let (_, mrr) = _parse-touying-reducer(
            self: minimal-self + (waypoints: (:), subslide: 9999),
            base: render-base,
            index: 9999,
            reducer-data,
          )
          mrr
        } else {
          let (
            _,
            mrr,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: minimal-self + (waypoints: (:), subslide: 9999),
            base: render-base,
            index: 9999,
            raw-content,
          )
          mrr
        }
        let repeat = calc.max(max-rep-raw, ..resolved-wp.values(), 1)
        let cwp = _compute-waypoint-ranges(resolved-wp, repeat, so, dr)
        let target = if recall-subslide == auto {
          repeat
        } else if (
          type(recall-subslide) == label
            or (
              type(recall-subslide) == dictionary
                and recall-subslide.at("kind", default: "") in waypoint-kinds
            )
        ) {
          // cwp is always this content's own *local* (base=1) waypoint
          // map — never an outer slide's — so the resolved position must
          // be shifted by (render-base - 1) to land in the same absolute
          // numbering as `repeat`/`max-rep-raw` above. Kept as one
          // parenthesized expression: a bare `+`/`-` starting a new line
          // in a Typst code block is parsed as its own statement (unary
          // +/-), not a continuation of the previous line — splitting
          // this across lines without wrapping it silently produced three
          // sibling int values that Typst then tried (and failed) to
          // join, instead of one arithmetic expression.
          (
            _resolve-waypoint-to-int((waypoints: cwp), recall-subslide)
              + render-base
              - 1
          )
        } else {
          utils.resolve-negative-subslides(
            repeat,
            recall-subslide,
            base: render-base,
          )
        }
        let render-self = (
          minimal-self
            + (
              waypoints: cwp,
              subslide: target,
            )
        )
        if reducer-data != none {
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
            raw-content,
          )
          conts.sum(default: none)
        }
      } else {
        if recall-subslide != auto {
          panic(
            "touying-recall: label "
              + repr(raw-label)
              + " refers to content with no subslide dimension, but "
              + "subslide: "
              + repr(recall-subslide)
              + " was given.",
          )
        }
        let found = query(raw-label)
        if found.len() == 0 {
          panic(
            "touying-recall: label "
              + repr(raw-label)
              + " was not found in the document.",
          )
        }
        found.first()
      }
    }
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
    columns,
    place,
    rotate,
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
            repetitions += it.body.value.n
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
            if first == repetitions + 1 {
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
            if first == repetitions + 1 {
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
    // The spacing that should border a covered run next to the list/enum/terms
    // item `it`. When the list spacing is `auto` we fall back to paragraph-
    // derived spacing (nontight -> par.spacing, tight -> par.leading); otherwise
    // the user set an explicit value we can read off directly.
    let list-spacing-for(it) = {
      if spacing-is-auto(it) {
        // would yield `auto` which is a par.spacing for the block.
        if self.at("nontight-list-enum-and-terms", default: true) {
          //cannot set list thightness via set rule somehow. if user uses magic.nontight locally we can't detect that, so we just assume he only uses the config. thus this might break.
          par.spacing
        } else {
          par.leading
        }
      } else if it.func() == list.item {
        list.spacing
      } else if it.func() == enum.item {
        enum.spacing
      } else if it.func() == terms.item {
        terms.spacing
      } else {
        par.spacing
      }
    }
    // `next-is-list` is a look-ahead hint: is the first *following* visible
    // element (after this covered run) a list/enum/terms item? It is needed to
    // correct the spacing *below* the covered block, which cannot be derived
    // from `items`/`last-result` alone (e.g. the #meanwhile case).
    let cover-hidden(cover-fn, items, last-result, next-is-list: false) = {
      // First non-space hidden element (borders the gap *above* the block)
      let first-pos = items.position(item => not tree.is-space(item))
      let first-is-list = (
        first-pos != none and _is-list-item(items.at(first-pos))
      )
      // Last non-space hidden element (borders the gap *below* the block)
      let last-hidden-item = {
        let found = none
        for i in range(items.len()) {
          let item = items.at(items.len() - 1 - i)
          if tree.is-space(item) {
            // skip space nodes only
          } else {
            found = item
            break
          }
        }
        found
      }
      let last-hidden-is-list = (
        last-hidden-item != none and _is-list-item(last-hidden-item)
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
          if tree.is-space(item) {
            // skip space nodes only
          } else {
            found = _is-list-item(item)
            break
          }
        }
        found
      }
      let covered = cover-fn(items.sum())
      // The gap *above* the covered block is broken when the last visible and
      // first hidden elements are both list items (a list interrupted by a
      // #pause). The gap *below* is broken symmetrically when the last hidden
      // and the next visible elements are both list items — e.g. a #meanwhile
      // that reveals further list items right after a covered run. Each side is
      // corrected independently; a paragraph / break / end on either side keeps
      // the natural (auto) spacing.
      let above-needs = first-is-list and last-is-list
      let below-needs = last-hidden-is-list and next-is-list
      if above-needs or below-needs {
        // construct a block around the covered content that corrects spacing.
        context block(
          above: if above-needs {
            list-spacing-for(items.at(first-pos))
          } else {
            auto
          },
          below: if below-needs {
            list-spacing-for(last-hidden-item)
          } else {
            auto
          },
          covered,
        )
      } else {
        covered
      }
    }

    // Flatten sequences and handle each child element
    let children = if tree.is-sequence(it) {
      it.children
    } else {
      (it,)
    }

    // Look ahead from `from-index`: is the first following non-space sibling a
    // list/enum/terms item? Used at flush sites to decide whether a covered run
    // needs list-spacing *below* it (the visible-list-after-covered case, e.g.
    // #meanwhile). Stops at the first non-space element, so an intervening
    // parbreak/linebreak (an intentional list break) correctly yields false.
    let next-sibling-is-list(from-index) = {
      let j = from-index + 1
      let res = false
      while j < children.len() {
        let sibling = children.at(j)
        if tree.is-space(sibling) {
          j += 1
        } else {
          res = _is-list-item(sibling)
          break
        }
      }
      res
    }

    // Process each child element for animation markers and content types
    for _child_i in range(children.len()) {
      let child = children.at(_child_i)
      let recall-breadcrumb = maybe-build-recall-breadcrumb(child)
      if recall-breadcrumb != none {
        if repetitions <= index or not need-cover {
          result.push(recall-breadcrumb)
        } else {
          hidden-parts.push(recall-breadcrumb)
        }
      }
      if (
        type(child) == content
          and child.func() == metadata
          and type(child.value) == dictionary
      ) {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            repetitions += child.value.n
            // Track the peak repetitions so that a subsequent negative jump doesn't
            // cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
            // If we jumped back into the visible zone, flush hidden-parts in order
            // (so they appear before subsequent visible content, not after it)
            if hidden-parts.len() != 0 and repetitions <= index {
              result.push(cover-hidden(
                cover,
                hidden-parts,
                result,
                next-is-list: next-sibling-is-list(_child_i),
              ))
              hidden-parts = ()
            }
          } else {
            // absolute: reveal all hidden content then jump to target subslide.
            // Visible content (e.g. list items) may follow directly, so look
            // ahead to correct the spacing below the covered run.
            if hidden-parts.len() != 0 {
              result.push(cover-hidden(
                cover,
                hidden-parts,
                result,
                next-is-list: next-sibling-is-list(_child_i),
              ))
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
          // If labeled, attach the real label directly to the rendered
          // output (wrapped in `block` — reducer output is already
          // effectively block-level, so this doesn't change layout) so the
          // label is genuinely findable via query()/@ref, not just stored
          // inside the metadata dict. Only on the slide's own last
          // subslide, so the label always points at the reducer's true
          // final state, and so a multi-subslide slide doesn't attach the
          // same real label more than once across multiple rendered pages.
          let real-label = child.value.at("label", default: none)
          let cont = if (
            cont != none
              and real-label != none
              and self.at("subslide", default: none)
                == self.at(
                  "repeat",
                  default: none,
                )
          ) {
            [#block(cont)#real-label]
          } else {
            cont
          }
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
          let subslides-spec = child.value.subslides
          let use-slide-context = child.value.at("base", default: auto) == auto
          let render-base = if use-slide-context { repetitions } else {
            child.value.base
          }
          // start:/repeat-last: anchor this content's own progression to a
          // point in the *enclosing* slide's own numbering — a separate
          // concern from base: (which only ever affects this content's own
          // internal pause-numbering, never the outer slide's). No effect
          // in article mode, which has no outer subslide progression to
          // anchor against.
          let start-spec = child.value.at("start", default: auto)
          let repeat-last-spec = child.value.at("repeat-last", default: true)
          if (
            self.at("article-mode", default: false)
              and (start-spec != auto or repeat-last-spec != true)
          ) {
            extern.warning(
              "touying-render: start:/repeat-last: have no effect in "
                + "article mode (there is no subslide progression to gate "
                + "against). Wrap this call in #slides-only[...] to "
                + "suppress this warning once you've confirmed that's what "
                + "you want.",
            )
            start-spec = auto
            repeat-last-spec = true
          }
          // Compute render context (inlined from _prepare-render-context)
          let reducer-data = _find-reducer-meta(inline-content)
          let (raw-wp, so, dr) = _collect-waypoints(inline-content)
          let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
          // Probe `body`'s own natural stage count by walking it at an index
          // past every conceivable stage. `last-subslide` counts for just as
          // much as `mrr` here: content whose extent comes from a fn-wrapper
          // (`uncover`, `only`, `alternatives`, ...) rather than from `#pause`
          // reports it *only* there — `_parse-content-into-results-and-repetitions`
          // hands the two back separately and leaves combining them to its
          // caller (`_parse-touying-reducer` already folds them itself, hence
          // the asymmetry between the branches).
          let probe(wp) = if reducer-data != none {
            let (_, mrr) = _parse-touying-reducer(
              self: self + (waypoints: wp, subslide: 9999),
              base: render-base,
              index: 9999,
              reducer-data,
            )
            mrr
          } else {
            let (
              _,
              mrr,
              ls,
              _,
              _,
            ) = _parse-content-into-results-and-repetitions(
              self: self + (waypoints: wp, subslide: 9999),
              base: render-base,
              index: 9999,
              inline-content,
            )
            calc.max(mrr, ls)
          }
          // Two passes, because the waypoint map and the repeat count are
          // mutually dependent: `_compute-waypoint-ranges` needs a repeat
          // count to close every range against, but a waypoint's own implicit
          // advance only fires for a label that's *in* the map — so a
          // single pass over an empty map silently drops that advance, and
          // everything the advance pushes forward with it. Pass one measures
          // against no waypoints at all, pass two re-measures against the
          // provisional map that first measurement makes computable. Their
          // start positions come from `_collect-waypoints`' own static walk
          // (`resolved-wp`), so the second pass can only ever grow the count.
          let provisional-cwp = _compute-waypoint-ranges(
            resolved-wp,
            calc.max(probe((:)), ..resolved-wp.values(), 1),
            so,
            dr,
          )
          let content-mrr = probe(provisional-cwp)
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
          // start: is resolved against the *outer* slide's own waypoints
          // (self.waypoints) — a completely separate lookup from cwp above,
          // which resolves subslide: against either this content's own
          // local waypoints or (when use-slide-context) the outer ones.
          let start-resolved = if start-spec == auto {
            none
          } else if (
            type(start-spec) == label
              or (
                type(start-spec) == dictionary
                  and start-spec.at("kind", default: "") in waypoint-kinds
              )
          ) {
            _resolve-waypoint-to-int(self, start-spec)
          } else {
            start-spec
          }
          // `is-bare-auto` (`subslides: auto` with no `start:`) is left
          // completely untouched by everything below: it's the
          // self-advancing "miniature preview" mode — always tracks the
          // outer slide's own raw index, unbounded, no member list, no
          // repetitions contribution beyond `content-mrr`. Anyone who wants
          // stepped/held semantics instead reaches for an explicit range
          // (e.g. `subslides: "1-"`) rather than `auto`.
          let is-bare-auto = subslides-spec == auto and start-resolved == none
          // For every other case, `subslides:` resolves to an ordered,
          // non-empty list of this content's own absolute subslide
          // indices (`render-base`-shifted, matching `rp`'s own
          // convention) — a single-point spec (a plain int, `get-first`,
          // `get-last`, ...) simply comes back as a one-element list, so
          // the stepping logic just below needs no cardinality special
          // case: `auto` + `start:` steps through this content's *entire*
          // natural range (unchanged from before — now just reframed as
          // the identity member list `1..content-repeat` instead of a
          // bespoke clamp formula), and an explicit range/waypoint/string
          // spec steps through whatever subset it captures.
          let targets = if is-bare-auto {
            () // unused; is-bare-auto short-circuits before this is read
          } else if subslides-spec == auto {
            range(1, content-repeat + 1)
          } else {
            let spec = subslides-spec
            let wp-self = self + (waypoints: cwp)
            if (
              type(spec) == label
                or (
                  type(spec) == dictionary
                    and spec.at("kind", default: "") in waypoint-kinds
                )
            ) {
              // cwp may be this content's own *local* (base=1) waypoint map
              // (not use-slide-context) — shift every member by
              // (render-base - 1) to land in the same absolute numbering
              // as `rp` below. When use-slide-context, cwp is already the
              // outer slide's own absolute waypoints, so no shift is
              // needed — but a `not-wp` marker there must enumerate over
              // the *outer* slide's own repeat count, not this content's.
              let bound = if use-slide-context {
                self.at("repeat", default: content-repeat)
              } else {
                content-repeat
              }
              let raw-members = _resolve-waypoint-to-members(
                wp-self,
                spec,
                bound,
              )
              if use-slide-context { raw-members } else {
                raw-members.map(m => m + render-base - 1)
              }
            } else if type(spec) == str and spec == "h" {
              // Bare "h" (only bare — never composed into a larger range
              // like "h-3") is the one escape hatch for referencing the
              // surrounding slide's current position from within
              // subslides: — "h" lives in the *surrounding* counter, every
              // plain number here lives in `body`'s own *local* one,
              // and mixing the two within a single string would silently
              // blend both numbering axes into one spec.
              (render-base,)
            } else if type(spec) == str and spec == "!h" {
              _members-in-range("!" + str(render-base), render-base, rp)
            } else if type(spec) == str {
              // Absolute numbering, same convention as the plain-int case
              // just below — bounds are `[render-base, rp]`.
              _resolve-string-to-members(spec, render-base, rp)
            } else if type(spec) == int {
              // `rp` is the absolute final counter value (it already
              // includes `render-base`), so convert it to a plain stage
              // count before resolving negative indices relative to `base`.
              (
                utils.resolve-negative-subslides(
                  rp - render-base + 1,
                  spec,
                  base: render-base,
                ),
              )
            } else { (rp,) }
          }
          // Where, in the *outer* slide's own numbering, this content's
          // member list begins stepping through — `start:` if given,
          // otherwise the outer slide's very first subslide (matching
          // `is-visible` below, which is unconditionally `true` whenever
          // no `start:` was given: the member list holds on its last
          // member forever once exhausted, with nothing to gate).
          let anchor = if start-resolved == none { 1 } else { start-resolved }
          let target = if is-bare-auto {
            index
          } else {
            let stage = calc.clamp(index - anchor + 1, 1, targets.len())
            targets.at(stage - 1)
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
          // Visibility: with no explicit start:, always visible — today's
          // unconditional behavior, unchanged. With an explicit start:,
          // absent entirely (like `only`, not `uncover` — no reserved
          // layout space) before it's reached; visible from then on — held
          // forever with repeat-last: true (default), or removed again
          // once past this content's own natural duration
          // (start + targets.len() - 1) with repeat-last: false. Duration
          // is measured in *exposed members* (targets.len()), not in
          // content-repeat's full natural length — a frozen single-member
          // spec's duration is 1 stage, not however many stages `body`
          // happens to have overall; is-bare-auto never reaches this
          // branch (it always has start-resolved == none).
          let is-visible = if start-resolved == none {
            true
          } else if index < start-resolved {
            false
          } else if repeat-last-spec {
            true
          } else {
            index <= start-resolved + targets.len() - 1
          }
          if cont != none and (is-visible or not need-cover) {
            result.push(cont)
          }
          // This content's animation grows the outer slide to hold every
          // stage it will step through — exactly as an `#uncover` spanning
          // that many subslides would, and via the same channel: it raises
          // `last-subslide`, never the pause cursor (`repetitions`). The
          // distinction is what the surrounding siblings see. Reserving
          // subslides is not the same as consuming them, so plain content
          // written after this call stays visible from the slide's first
          // subslide and a following `#pause` counts from where the flow
          // already was; consuming them instead — what `item-by-item` opts
          // into with `advances-flow` — would push every later sibling past
          // this content's end, which is right for a stand-in for a run of
          // pauses but wrong for content rendered at a fixed point.
          //
          // is-bare-auto contributes `content-mrr` (not `content-repeat`),
          // the historical value for its own self-advancing semantics. Every
          // other case (auto + start:, or any explicit subslides: spec,
          // single- or multi-member alike) contributes
          // `anchor + targets.len() - 1`: for auto + start: that's the same
          // count as before (targets.len() == content-repeat there), and for
          // an explicit spec it guarantees the outer slide actually grows
          // enough subslides to reach — and, with repeat-last: false, later
          // remove — every member being stepped through.
          last-subslide = calc.max(
            last-subslide,
            if is-bare-auto { content-mrr } else {
              anchor + targets.len() - 1
            },
          )
        } else if kind == "touying-fn-wrapper" {
          // Handle function wrappers (uncover, only, alternatives, etc.)
          // These always escape the pause zone: they handle their own subslide
          // visibility internally, so they must never be pushed to hidden-parts.
          has-fn-wrapper = true
          let nextrepetitions = repetitions
          let extra-args = (:)
          if child.value.last-subslide != none {
            // calc.max throughout, to stop a callback from *decreasing*
            // either counter.
            let resolved = if type(child.value.last-subslide) == function {
              let (callback-last-subslide, callback-extra-args) = (
                child.value.last-subslide
              )(
                repetitions,
              )
              extra-args = callback-extra-args
              callback-last-subslide
            } else {
              child.value.last-subslide
            }
            last-subslide = calc.max(last-subslide, resolved)
            // A flow-advancing wrapper (item-by-item) stands in for a run of
            // pauses, so it hands the pause cursor on at the end of its own
            // range — via nextrepetitions, since `repetitions` itself must
            // stay put for the duration of the call below (the wrapper's own
            // `start:` is resolved from it). Every other wrapper only
            // animates its own body and leaves the cursor alone.
            if child.value.at("advances-flow", default: false) {
              nextrepetitions = calc.max(nextrepetitions, resolved)
            }
          }
          // Resolve any "passive" mark (touying-fn-wrapper-raw, e.g.
          // #alert; or a touying-recall fallback, i.e.
          // touying-slide-recaller) found anywhere inside each positional
          // arg's content tree — not just when the mark is the *entire*
          // arg, so `text #alert[...] more text` nests inside
          // `#uncover[...]` exactly like a bare `#uncover[#alert[...]]`
          // does. Passive marks have no multi-subslide behavior of their
          // own (unlike touying-render, which can grow the outer slide's
          // own subslide count and so keeps its own dedicated dispatch),
          // so they compose with uncover/only/alternatives by being fully
          // resolved in place before the wrapper's own visibility logic
          // runs — nesting lets the outer wrapper gate/hide them instead
          // of needing any visibility parameter of their own.
          let pos-args = child
            .value
            .args
            .pos()
            .map(c => _resolve-passive-marks(
              c,
              self,
              v => resolve-recall-fallback(
                self,
                v.raw-label,
                v.at("subslides", default: none),
                v.at("base", default: auto),
              ),
            ))

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
          // Handle raw function wrappers (e.g. #alert). First resolve any
          // touying-recall fallback found anywhere inside this one's own
          // positional args — e.g. `#alert[#touying-recall(<label>)]`.
          // Nested touying-fn-wrapper-raw marks are deliberately *not*
          // resolved here: the recursive parse below reaches this same branch
          // for them, so their own bodies get parsed too. Resolving them
          // eagerly would swallow a `#pause`/`#meanwhile` sitting inside a
          // nested `#alert[..]`.
          let raw-bodies = child
            .value
            .args
            .pos()
            .map(c => tree.resolve-marks(
              c,
              ("touying-slide-recaller",),
              v => resolve-recall-fallback(
                self,
                v.raw-label,
                v.at("subslides", default: none),
                v.at("base", default: auto),
              ),
            ))
          // Parse the body so markers inside it are counted and rendered like
          // anywhere else: #pause/#meanwhile advance the subslide count, and a
          // touying-fn-wrapper (#only, #uncover, #effect, ..) is resolved here
          // instead of reaching the wrapped function as a raw metadata mark,
          // which would trip the unsupported-mark panic.
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
            show-delayed-wrapper: show-delayed-wrapper,
            ..raw-bodies,
          )
          // `would-be-hidden` uses the repetitions this wrapper was *entered*
          // at, not `calc.min(repetitions, final-repetitions)` as the container
          // branches do: a #meanwhile inside rewinds final-repetitions to 1, and
          // taking the min would then wrongly declare the whole wrapper visible
          // and reveal the content sitting before that #meanwhile too early.
          let would-be-hidden = repetitions > index and need-cover
          let meanwhile-escaped = final-repetitions < repetitions
          // Propagate a #meanwhile that fired inside the wrapper
          if meanwhile-escaped {
            if hidden-parts.len() != 0 {
              result.push(cover-hidden(cover, hidden-parts, result))
              hidden-parts = ()
            }
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
          if would-be-hidden and (inner-has-fn-wrapper or meanwhile-escaped) {
            // Two-pass: the body has to decide its own visibility, so re-run it
            // with the outer need-cover and push to result rather than
            // hidden-parts. A fn-wrapper directly inside a hidden wrapper would
            // otherwise be covered twice; a #meanwhile needs the inner parse to
            // cover what comes before it while revealing what comes after.
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
              show-delayed-wrapper: show-delayed-wrapper,
              ..raw-bodies,
            )
            result.push((child.value.fn)(
              self: self,
              ..conts2,
              ..child.value.args.named(),
            ))
            has-fn-wrapper = true
            max-repetitions = calc.max(max-repetitions, inner-max-repetitions2)
          } else {
            let rendered = (child.value.fn)(
              self: self,
              ..conts,
              ..child.value.args.named(),
            )
            if would-be-hidden {
              hidden-parts.push(rendered)
            } else {
              result.push(rendered)
            }
            if inner-has-fn-wrapper { has-fn-wrapper = true }
            max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
          }
          repetitions = final-repetitions
          last-subslide = calc.max(last-subslide, next-last-subslide)
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
            if first == repetitions + 1 {
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
            if first == repetitions + 1 {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output.
        } else if kind == "touying-slide-recaller" {
          // Used inside a slide's own body: there's no sensible "recall a
          // whole other slide from within this slide's content" semantic,
          // so this always goes through the recall fallback (reducer or
          // arbitrary labeled content), never the whole-slide recaller-map.
          let recalled = resolve-recall-fallback(
            self,
            child.value.raw-label,
            child.value.at("subslides", default: none),
            child.value.at("base", default: auto),
          )
          if repetitions <= index or not need-cover {
            result.push(recalled)
          } else {
            hidden-parts.push(recalled)
          }
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
      } else if tree.is-sequence(child) {
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
      } else if tree.is-styled(child) {
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
          (child, cont) => tree.reconstruct-styled(child, cont),
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
          (child, cont) => tree.reconstruct(
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
        let reconstructed-table = tree.reconstruct-table-like(
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
      } else if type(child) == content and child.func() == footnote {
        if repetitions <= index or not need-cover {
          if labeled(child.func()) and child.has("label") {
            result.push([#footnote(child.body)#child.label])
          } else {
            result.push(footnote(child.body))
          }
        } else if not utils.cover-hides-footnote(self) {
          // Only a genuinely-hiding cover needs the placeholder trick below: native
          // `hide()` does not by itself hide a footnote's entry, so real footnotes
          // must not be created while covered that way. Visual-only cover methods
          // (color-changing-cover, alpha-changing-cover, ...) are meant to keep
          // content visible, just de-emphasized - a footnote under one of those
          // should still show its real marker and entry, recolored like everything
          // else, so push it through the normal cover mechanism instead.
          if labeled(child.func()) and child.has("label") {
            hidden-parts.push([#footnote(child.body)#child.label])
          } else {
            hidden-parts.push(footnote(child.body))
          }
        } else {
          // `hide()` only hides a footnote's marker, not the entry it queues at the
          // bottom of the page - so a covered footnote must not call `footnote()` at
          // all, or its entry leaks through before it should be revealed. To still
          // reserve the same marker width (so revealing it later doesn't reflow the
          // paragraph), advance the real footnote counter and draw just the
          // superscript number. Reading/writing the real counter - rather than
          // tracking our own - keeps this correct even if the user manipulates
          // `counter(footnote)` themselves elsewhere in the document.
          hidden-parts.push(context {
            let n = counter(footnote).get().first() + 1
            counter(footnote).update(n)
            let footnote-style = self.at("footnote-style", default: auto)
            if footnote-style == auto {
              super[#numbering(footnote.numbering, n)]
            } else {
              // Calling `footnote-style` directly on a constructed `footnote(..)`
              // would actually lay that footnote out for real the moment this
              // content is shown (even inside `hide()`) - double-counting the
              // counter and leaking its own entry. `measure` runs that lookup in
              // an isolated, discarded layout, so only the resulting width (not
              // the side effects) survives - which is all a placeholder needs.
              let fake = footnote(numbering: footnote.numbering, [])
              box(width: measure(footnote-style(fake)).width)
            }
          })
        }
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
          (child, cont) => tree.reconstruct(
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
          (child, cont) => tree.reconstruct(
            named: true,
            body-name: "description",
            labeled: labeled(child.func()),
            child,
            cont,
          ),
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


/// Build a query-based recall for a label that isn't a registered
/// whole-slide recall target: a labeled `touying-reducer`, or arbitrary
/// labeled content — which may itself have more than one subslide of its
/// own (see the "labeled + multi-repetition" breadcrumb mechanism above).
///
/// Always checks the derived breadcrumb label
/// (`<label>:touying-recall-breadcrumb`) first, regardless of whether an
/// explicit subslide was requested — a `touying-reducer`'s own real label
/// is never itself attached to anything (it only lives inside the
/// metadata dict), so `subslide: auto` still needs the breadcrumb's raw
/// content to render *anything* for a reducer, not just to pick a specific
/// stage. Only falls back to querying the original label directly when no
/// breadcrumb exists — i.e. genuinely static, non-reducer content with no
/// subslide dimension at all, where the original label already points at
/// the final state directly and any explicit subslide is an error.
///
/// -> content
#let _build-native-recall(lbl, subslides, base) = {
  let subslides = if subslides == none { auto } else { subslides }
  if (
    subslides != auto
      and type(subslides) != int
      and type(subslides) != label
      and not (
        type(subslides) == dictionary
          and subslides.at("kind", default: "") in waypoint-kinds
      )
  ) {
    panic(
      "touying-recall: subslides: "
        + repr(subslides)
        + " is not supported outside a whole-slide target — only "
        + "auto/none, an int subslide number, or a waypoint label/marker "
        + "are supported here.",
    )
  }
  context {
    let breadcrumb-label = label(str(lbl) + ":touying-recall-breadcrumb")
    let breadcrumb-found = query(breadcrumb-label)
    if breadcrumb-found.len() > 0 {
      let raw-content = breadcrumb-found.first().value.content
      let minimal-self = (
        methods: (cover: utils.method-wrapper(hide)),
        waypoints: (:),
        subslide: 1,
      )
      let render-base = if base == auto { 1 } else { base }
      let (reducer-data, cwp, repeat, _) = _prepare-render-context(
        minimal-self,
        raw-content,
        render-base,
      )
      let target = if subslides == auto {
        repeat
      } else if (
        type(subslides) == label
          or (
            type(subslides) == dictionary
              and subslides.at("kind", default: "") in waypoint-kinds
          )
      ) {
        // cwp is always this content's own *local* (base=1) waypoint map —
        // never an outer slide's — so the resolved position must be
        // shifted by (render-base - 1) to land in the same absolute
        // numbering as `repeat` above.
        _resolve-waypoint-to-int((waypoints: cwp), subslides) + render-base - 1
      } else {
        utils.resolve-negative-subslides(repeat, subslides, base: render-base)
      }
      _render-at-subslide(
        minimal-self,
        raw-content,
        reducer-data,
        cwp,
        render-base,
        target,
      )
    } else {
      if subslides != auto {
        panic(
          "touying-recall: label "
            + repr(lbl)
            + " refers to content with no subslide dimension, but subslides: "
            + repr(subslides)
            + " was given.",
        )
      }
      let found = query(lbl)
      if found.len() == 0 {
        panic(
          "touying-recall: label "
            + repr(lbl)
            + " was not found in the document.",
        )
      }
      found.first()
    }
  }
}

