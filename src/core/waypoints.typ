#import "../utils.typ"


/// ------------------------------------------------
/// Waypoints animation functions via metadata markers
/// (by Zral0kh)
/// ------------------------------------------------

/// the different metadata kinds used for waypoints and waypoint markers.
#let waypoint-kinds = (
  "waypoint",
  "implicit-waypoint",
  "waypoint-first",
  "waypoint-last",
  "waypoint-from",
  "waypoint-until",
  "waypoint-prev",
  "waypoint-next",
  "waypoint-not",
).map(el => "touying-" + el)

/// Declare a named waypoint in the slide's subslide sequence.
///
/// A waypoint names a set of subslide positions so that it can be referred to
/// by label in `uncover`, `only`, `effect`, `alternatives`, and other animation
/// functions. This lets you avoid counting subslide numbers manually.
///
/// By default, a waypoint call also acts as a `#pause` (advancing to the next subslide).
/// Set `advance: false` to mark the current position without advancing.
///
/// A waypoint covers all subslides from its declaration until the next waypoint
/// is declared (or the end of the slide).
///
/// You can also set the starting subslide of a waypoint with the `start` argument, which allows for more flexible control, independent of how your content may be structured. Circular waypoint dependencies will panic!
/// Thus passing `start` will basically act like a `jump(start)` at the position of the waypoint.
///
/// Note that your labels need to be slide-unique. They need not be globally
/// unique, but must be unique within a single slide.
///
/// You can use hierarchical labels with `:` separators (e.g. `<part:intro>`).
/// When referencing `<part>`, all waypoints starting with `part:` are combined.
///
/// Example:
///
/// ```typst
/// Some content
/// #waypoint(<reveal>)
/// #uncover(<reveal>)[Revealed content]
/// #waypoint(<highlight>)
/// #effect(text.with(fill: red), <highlight>)[Highlighted]
/// ```
///
/// - lbl (label): The label for this waypoint.
///
/// - advance (bool): If `true` (default), acts as a `#pause` before marking.
///   If `false`, marks the current subslide position without advancing.
///
/// - start (auto | int | label): The starting subslide for this waypoint. By default the location in the content and depends on `advance`. If set ignores `advance` and allows to specify a subslide index or a waypoint.
///
/// -> content
#let waypoint(lbl, advance: true, start: auto) = {
  assert(
    type(lbl) == label,
    message: "waypoint: expected a label, got " + str(type(lbl)),
  )
  let start-value = if type(start) == label {
    str(start)
  } else {
    start
  }
  [#metadata((
    kind: "touying-waypoint",
    label: str(lbl),
    advance: advance,
    start: start-value,
  ))<touying-temporary-mark>]
}


/// Get the first subslide number of a waypoint.
///
/// Returns a marker dictionary that will be resolved automatically when used as
/// a `visible-subslides` argument in `uncover`, `only`, `effect`, etc.
///
/// Example: `#only(get-first(<my-label>))[content]`
///
/// - lbl (label): The waypoint label.
///
/// -> dictionary
#let get-first(lbl) = {
  assert(
    type(lbl) == label,
    message: "get-first: expected a label, got " + str(type(lbl)),
  )
  (
    kind: "touying-waypoint-first",
    label: str(lbl),
  )
}


/// Get the last subslide number of a waypoint.
///
/// Returns a marker dictionary that will be resolved automatically when used as
/// a `visible-subslides` argument in `uncover`, `only`, `effect`, etc.
///
/// Example: `#only(get-last(<my-label>))[content]`
///
/// - lbl (label): The waypoint label.
///
/// -> dictionary
#let get-last(lbl) = {
  assert(
    type(lbl) == label,
    message: "get-last: expected a label, got " + str(type(lbl)),
  )
  (
    kind: "touying-waypoint-last",
    label: str(lbl),
  )
}


/// Create a "from-wp" range starting at a waypoint (inclusive to end of slide).
///
/// Returns a range marker visible from the waypoint's first subslide onward.
/// Does *not* create a waypoint — the referenced label must be defined
/// elsewhere (via `#waypoint()` or an implicit waypoint in `#uncover`, etc.).
///
/// Can be composed with `prev-wp` / `next-wp`:
/// `from-wp(next-wp(<my-label>))` starts at the waypoint after `<my-label>`.
///
/// Combine with `until-wp` in an array for bounded ranges:
/// `(from-wp(<a>), until-wp(<b>))` — visible from `<a>` to just before `<b>`.
///
/// - wp (label | dictionary): A waypoint label or a shifted reference
///   (e.g. `next-wp(<label>)`).
///
/// -> dictionary
#let from-wp(wp) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "from-wp: expected a label or waypoint marker, got "
      + str(type(wp)),
  )
  (
    kind: "touying-waypoint-from",
    inner: if type(wp) == label {
      str(wp)
    } else {
      wp
    },
  )
}


/// Create an "until-wp" range ending just before a waypoint (exclusive).
///
/// Returns a range marker visible from subslide 1 up to (but not including)
/// the waypoint's first subslide.  Does *not* create a waypoint.
///
/// Can be composed with `prev-wp` / `next-wp`:
/// `until-wp(prev-wp(<my-label>))` ends before the waypoint preceding `<my-label>`.
///
/// Combine with `from-wp` in an array for bounded ranges:
/// `(from-wp(<a>), until-wp(<b>))` — visible from `<a>` to just before `<b>`.
///
/// - wp (label | dictionary): A waypoint label or a shifted reference.
///
/// -> dictionary
#let until-wp(wp) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "until-wp: expected a label or waypoint marker, got "
      + str(type(wp)),
  )
  (
    kind: "touying-waypoint-until",
    inner: if type(wp) == label {
      str(wp)
    } else {
      wp
    },
  )
}


/// Shift a waypoint reference to a previous waypoint in subslide order.
///
/// Given a waypoint label, returns a reference to the waypoint `amount` steps
/// before it.  `prev-wp(<c>, amount: 2)` is equivalent to
/// `prev-wp(prev-wp(<c>))`.
///
/// When applied to a `from-wp` or `until-wp` marker, the shift is pushed inward:
/// `prev-wp(from-wp(<c>))` becomes `from-wp(prev-wp(<c>))`.
///
/// - wp (label | dictionary): A waypoint label or marker to shift.
///
/// - amount (int): How many waypoints to step back. Default is `1`.
///
/// -> dictionary
#let prev-wp(wp, amount: 1) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "prev-wp: expected a label or waypoint marker, got "
      + str(type(wp)),
  )
  if type(wp) == label {
    (kind: "touying-waypoint-prev", inner: str(wp), amount: amount)
  } else if type(wp) == dictionary {
    let kind = wp.at("kind", default: none)
    if kind in ("touying-waypoint-from", "touying-waypoint-until") {
      // Push shift inward: prev-wp(from-wp(<x>)) → from-wp(prev-wp(<x>))
      (..wp, inner: prev-wp(wp.inner, amount: amount))
    } else {
      (kind: "touying-waypoint-prev", inner: wp, amount: amount)
    }
  } else {
    (kind: "touying-waypoint-prev", inner: wp, amount: amount)
  }
}


/// Shift a waypoint reference to a later waypoint in subslide order.
///
/// Given a waypoint label, returns a reference to the waypoint `amount` steps
/// after it.  `next-wp(<a>, amount: 2)` is equivalent to
/// `next-wp(next-wp(<a>))`.
///
/// When applied to a `from` or `until` marker, the shift is pushed inward:
/// `next-wp(until-wp(<a>))` becomes `until-wp(next-wp(<a>))`.
///
/// - wp (label | dictionary): A waypoint label or marker to shift.
///
/// - amount (int): How many waypoints to step forward. Default is `1`.
///
/// -> dictionary
#let next-wp(wp, amount: 1) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "next-wp: expected a label or waypoint marker, got "
      + str(type(wp)),
  )
  if type(wp) == label {
    (kind: "touying-waypoint-next", inner: str(wp), amount: amount)
  } else if type(wp) == dictionary {
    let kind = wp.at("kind", default: none)
    if kind in ("touying-waypoint-from", "touying-waypoint-until") {
      // Push shift inward: next-wp(until-wp(<x>)) → until-wp(next-wp(<x>))
      (..wp, inner: next-wp(wp.inner, amount: amount))
    } else {
      (kind: "touying-waypoint-next", inner: wp, amount: amount)
    }
  } else {
    (kind: "touying-waypoint-next", inner: wp, amount: amount)
  }
}


/// Negate a waypoint marker — visible on all subslides *except* the referenced ones.
///
/// Works with bare labels, `from-wp`, `until-wp`, `prev-wp`, `next-wp`,
/// `get-first`, `get-last`, or any other waypoint marker.
///
/// Like the `"!"` prefix for strings, `not-wp` cannot introduce new subslides —
/// it only masks existing ones.
///
/// Example: `#only(not-wp(<my-label>))[hidden during my-label]`
///
/// - wp (label | dictionary): A waypoint label or marker to negate.
///
/// -> dictionary
#let not-wp(wp) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "not-wp: expected a label or waypoint marker, got "
      + str(type(wp)),
  )
  (
    kind: "touying-waypoint-not",
    inner: if type(wp) == label {
      str(wp)
    } else {
      wp
    },
  )
}


// Cover function that discards hidden content (no placeholder).
// Used by block-recall and inline-render paths where covering is not needed.
#let _cover-never = items => none


/// ------------------------------------------------
/// Waypoint Collection
/// ------------------------------------------------



/// Check whether a waypoint label is already known — either exactly or
/// because a child in the hierarchy was registered earlier (e.g. `<top:sub>`
/// makes `<top>` known without storing a synthetic parent entry).
#let _waypoint-known(waypoints, lbl) = {
  if lbl in waypoints {
    return true
  }
  let prefix = lbl + ":"
  waypoints.keys().any(k => k.starts-with(prefix))
}


/// Resolve explicit waypoint `start` overrides.
///
/// Builds a dependency forest from waypoints with `start` parameters and
/// resolves them in topological order (roots first). Waypoints with
/// `start: int` are resolved directly. Waypoints with `start: <label>`
/// inherit the position of the referenced waypoint.
/// Calling a non-existant parent of a hierarchical label will yield the position of the first child.
///
/// Panics on circular dependencies.
///
/// - raw-waypoints (dictionary): Map of label → raw subslide number.
///
/// - start-overrides (dictionary): Map of label → start spec (int or string).
///
/// -> dictionary
#let _resolve-waypoint-forest(raw-waypoints, start-overrides) = {
  if start-overrides.len() == 0 {
    return raw-waypoints
  }

  // Phase 1: Apply int overrides directly
  for (lbl, start) in start-overrides.pairs() {
    if type(start) == int {
      raw-waypoints.insert(lbl, start)
    }
  }

  // Phase 2: Iteratively resolve label references
  // Each iteration resolves waypoints whose dependency is already resolved.
  // If no progress is made, a cycle exists.
  let pending = (:)
  for (lbl, start) in start-overrides.pairs() {
    if type(start) == str {
      pending.insert(lbl, start)
    }
  }
  //returns true if parent is an ancestor of child, i.e. if child starts with parent + ":"
  let _check_parent_label(parent, child) = {
    let prefix = parent + ":"
    return child.starts-with(prefix)
  }

  let max-iterations = pending.len() + 1
  let iteration = 0
  while pending.len() > 0 {
    iteration += 1
    if iteration > max-iterations {
      panic(
        "Circular waypoint dependency detected among: "
          + pending.keys().join(", "),
      )
    }
    let sorted-keys = raw-waypoints.keys().sorted(key: k => raw-waypoints.at(k))
    let still-pending = (:)
    for (lbl, ref) in pending.pairs() {
      let resolved-child = sorted-keys.find(child => _check_parent_label(
        ref,
        child,
      ))
      if ref not in pending or resolved-child != none {
        // The referenced waypoint, or a child is already resolved
        assert(
          ref in raw-waypoints or resolved-child != none,
          message: "waypoint start: references unknown waypoint <" + ref + ">",
        )
        if resolved-child != none {
          ref = resolved-child
        }
        raw-waypoints.insert(lbl, raw-waypoints.at(ref))
      } else {
        still-pending.insert(lbl, ref)
      }
    }
    pending = still-pending
  }

  raw-waypoints
}



/// Compute waypoint ranges from raw waypoint positions.
///
/// Each waypoint covers subslides from its declared position until the next
/// waypoint starts (or the end of the slide for the last one).
///
/// When a waypoint uses `start` to jump backward, its predecessor's range
/// extends through the declaration point (the subslide the content was at
/// before the jump), allowing overlapping ranges.
///
/// - raw-waypoints (dictionary): Map of label → subslide number.
///
/// - total-repeat (int): Total number of subslides in the slide.
///
/// - start-overrides (dictionary): Map of label → start spec for explicit starts.
///
/// - decl-reps (dictionary): Map of label → effective repetitions at declaration.
///
/// -> dictionary
#let _compute-waypoint-ranges(
  raw-waypoints,
  total-repeat,
  start-overrides,
  decl-reps,
) = {
  if raw-waypoints.len() == 0 {
    return (:)
  }
  // Use content declaration order (dictionary insertion order) — a waypoint
  // captures all subslides until the next waypoint is declared in content,
  // regardless of subslide positions.
  let content-order = raw-waypoints.pairs()
  let result = (:)
  for (i, (lbl, first)) in content-order.enumerate() {
    let last = if i + 1 < content-order.len() {
      let (next-lbl, _) = content-order.at(i + 1)
      decl-reps.at(next-lbl, default: first)
    } else {
      total-repeat
    }
    // Ensure last >= first (ranges can overlap when explicit start jumps backward)
    let last = calc.max(first, last)
    result.insert(lbl, (first: first, last: last))
  }
  result
}



