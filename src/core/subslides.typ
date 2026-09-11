// Resolving which subslides a piece of content is visible on.
//
// A visibility spec can be a number, a range string like `"2-4"`, a waypoint
// or a marker built from one. Everything that turns such a spec into concrete
// subslide numbers lives here, so the parser, the animation functions and the
// slide splitter all agree on what a spec means.

#let _parse-subslide-indices(s) = {
  let parts = s.split(",").map(p => p.trim())
  let parse-part(part) = {
    let match-until = part.match(regex("^-([[:digit:]]+)$"))
    let match-beginning = part.match(regex("^([[:digit:]]+)-$"))
    let match-range = part.match(regex("^([[:digit:]]+)-([[:digit:]]+)$"))
    let match-single = part.match(regex("^([[:digit:]]+)$"))
    if match-until != none {
      let parsed = int(match-until.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      (until: parsed)
    } else if match-beginning != none {
      let parsed = int(match-beginning.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      (beginning: parsed)
    } else if match-range != none {
      let parsed-first = int(match-range.captures.first())
      let parsed-last = int(match-range.captures.last())
      // assert(parsed-first > 0, "parsed idx is non-positive")
      // assert(parsed-last > 0, "parsed idx is non-positive")
      (beginning: parsed-first, until: parsed-last)
    } else if match-single != none {
      let parsed = int(match-single.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      parsed
    } else {
      panic("failed to parse visible slide idx:" + part)
    }
  }
  parts.map(parse-part)
}

/// -> bool
#let check-visible(idx, visible-subslides) = {
  if type(visible-subslides) == int {
    idx == visible-subslides
  } else if type(visible-subslides) == array {
    visible-subslides.any(s => check-visible(idx, s))
  } else if type(visible-subslides) == str {
    if visible-subslides.starts-with("!") {
      // Negation: "!2-4" means everything except subslides 2-4
      not check-visible(idx, visible-subslides.slice(1))
    } else {
      let parts = _parse-subslide-indices(visible-subslides)
      check-visible(idx, parts)
    }
  } else if (
    type(visible-subslides) == content and visible-subslides.has("text")
  ) {
    let parts = _parse-subslide-indices(visible-subslides.text)
    check-visible(idx, parts)
  } else if type(visible-subslides) == dictionary {
    let kind = visible-subslides.at("kind", default: none)
    if kind == "not" {
      // Negation: visible everywhere except where inner is visible.
      not check-visible(idx, visible-subslides.inner)
    } else {
      let lower-okay = if "beginning" in visible-subslides {
        visible-subslides.beginning <= idx
      } else {
        true
      }

      let upper-okay = if "until" in visible-subslides {
        visible-subslides.until >= idx
      } else {
        true
      }

      lower-okay and upper-okay
    }
  } else {
    panic(
      "you may only provide a single integer, an array of integers, or a string, got:"
        + repr(visible-subslides),
    )
  }
}

/// Check if a subslide index is visible given a visibility specification.
///
/// Example: `check-visible(3, "2-")` returns `true`
///
/// - idx (int): The current subslide index.
///
/// - visible-subslides (int, array, str): Specifies which subslides are visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///
/// Resolve negative subslide indices relative to a total repeat count.
/// E.g. `-1` becomes the last subslide, `-2` the second-to-last.
///
/// Positive indices are absolute and, when `base` is not `1` (e.g. a reducer
/// block rendered with a custom `base` so its internal counter starts higher
/// than 1), are valid over `base..(base + repeat - 1)` rather than `1..repeat`.
/// Negative indices always count backward from the last subslide, so their
/// valid magnitude range (`1..repeat`) does not depend on `base`.
///
/// - repeat (int): Total number of subslides.
/// - idx (int, array): A subslide index or array of indices.
/// - base (int): The counter value of the first subslide. Default is `1`.
///
/// -> int or array
#let resolve-negative-subslides(repeat, idx, base: 1) = {
  let resolve-one(i) = {
    assert(i != 0, message: "idx cannot be zero")
    if i < 0 {
      assert(calc.abs(i) <= repeat, message: "idx out of bounds")
      base + repeat + i
    } else {
      assert(
        i >= base and i <= base + repeat - 1,
        message: "idx out of bounds",
      )
      i
    }
  }

  if type(idx) == array {
    idx.map(i => if type(i) == int { resolve-one(i) } else { i })
  } else if type(idx) == int {
    resolve-one(idx)
  } else {
    idx
  }
}

/// The placement effects `animate` understands as strings. See `animate` for
/// why placements are resolved rather than composed.
#let animate-placements = ("show", "cover", "remove")

#let _is-swap(eff) = (
  type(eff) == dictionary and eff.at("kind", default: none) == "touying-swap"
)

#let _is-placement(eff) = (
  (type(eff) == str and eff in animate-placements) or _is-swap(eff)
)

#let last-required-subslide(visible-subslides) = {
  if type(visible-subslides) == label {
    // Labels are resolved at render time; the pauses that define waypoints
    // already contribute to the repetitions count.  Return 1 (not 0) so that
    // the parser's two-pass escape hatch (next-last-subslide > 0) recognises
    // that a fn-wrapper exists inside a nested sequence.  A value of 1 never
    // inflates the repeat count because repetitions is always >= 1.
    1
  } else if type(visible-subslides) == int {
    visible-subslides
  } else if type(visible-subslides) == array {
    calc.max(..visible-subslides.map(s => last-required-subslide(s)))
  } else if type(visible-subslides) == str {
    if visible-subslides.starts-with("!") {
      // Negation cannot introduce new subslides, only use existing ones.
      0
    } else {
      let parts = _parse-subslide-indices(visible-subslides)
      last-required-subslide(parts)
    }
  } else if type(visible-subslides) == dictionary {
    let kind = visible-subslides.at("kind", default: none)
    if (
      kind
        in (
          "touying-waypoint-first",
          "touying-waypoint-last",
          "touying-waypoint-from",
          "touying-waypoint-until",
          "touying-waypoint-prev",
          "touying-waypoint-next",
          "touying-waypoint-not",
        )
    ) {
      // Will be resolved at render time; pauses determine repeat count.
      // Return 1 (not 0) so fn-wrapper escape hatch triggers (see label branch).
      1
    } else {
      let last = 0
      if "beginning" in visible-subslides {
        last = calc.max(last, visible-subslides.beginning)
      }
      if "until" in visible-subslides {
        last = calc.max(last, visible-subslides.until)
      }
      last
    }
  } else {
    panic(
      "you may only provide `auto`, a single integer, an array of integers, a string or a waypoint label or marker",
    )
  }
}
