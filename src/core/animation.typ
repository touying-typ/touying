#import "../utils.typ"
#import "waypoints.typ": from-wp // needed to support alternatives repeat-last with waypoints



/// ------------------------------------------------
/// Animation functions via metadata markers
/// ------------------------------------------------

/// Wrapper for a function to make it can receive `self` as an argument.
/// It is useful when you want to use `self` to get current subslide index, like `uncover` and `only` functions.
///
/// Example: `#let alternatives = touying-fn-wrapper.with(utils.alternatives)`
///
/// - fn (function): The function that will be called like `(self: none, ..args) => { .. }`.
///
/// - last-subslide (int): The max subslide count for the slide. Used by functions like `uncover`, `only`, and `alternatives-match` to determine the total number of subslides needed.
///
/// - repetitions (function): The repetitions for the function. It is useful for functions like `alternatives` with `start: auto`.
///
///   It accepts a `(repetitions, args)` and should return a (nextrepetitions, extra-args).
///
/// -> content
#let touying-fn-wrapper(
  fn,
  last-subslide: none,
  repetitions: none,
  ..args,
) = [#metadata((
  kind: "touying-fn-wrapper",
  fn: fn,
  args: args,
  last-subslide: last-subslide,
  repetitions: repetitions,
))<touying-temporary-mark>]

#import "blocks.typ": (
  alert, speaker-note, touying-equation, touying-fn-wrapper-raw, touying-mitex,
  touying-raw, touying-reducer,
)
/// Wrapper for a slide function to make it can receive `self` as an argument.
///
/// Notice: This function is necessary for the slide function to work in Touying.
///
/// Example:
///
/// ```typst
/// #let slide(..args) = touying-slide-wrapper(self => {
///   touying-slide(self: self, ..args)
/// })
/// ```
///
/// - fn (function): The function that will be called with an argument `self` like `self => { .. }`.
///
/// -> content
#let touying-slide-wrapper(fn) = [#metadata((
  kind: "touying-slide-wrapper",
  fn: fn,
))<touying-temporary-mark>]




/// Display content only in handout mode. (not presentation)
/// Don't reserve space when hidden, content is completely not existing there.
///
/// Example:
///
/// ```typst
/// #handout-only[This content is only visible in handout mode.]
/// ```
///
/// - body (content): The content to display in handout mode.
///
/// -> content
#let handout-only(body) = [#metadata((
  kind: "touying-slides-only",
  body: touying-fn-wrapper(
    utils.handout-only,
    body,
  ),
))<touying-temporary-mark>]

/// Display content only in presentation mode. (not handout)
/// Don't reserve space when hidden, content is completely not existing there.
///
/// Example:
///
/// ```typst
/// #presentation-only[This content is only visible in presentation mode.]
/// ```
///
/// - body (content): The content to display in presentation mode.
///
/// -> content
#let presentation-only(body) = [#metadata((
  kind: "touying-slides-only",
  body: touying-fn-wrapper(
    utils.presentation-only,
    body,
  ),
))<touying-temporary-mark>]



/// Content that only appears in handout or presentation (slides) mode.
///
/// In document mode this content is stripped entirely. Use this for
/// visual-only elements that don't make sense in a written document
/// (e.g., decorative graphics, audience prompts, transition animations).
///
/// Example:
///
/// ```typst
/// #slides-only[
///   _Live demo here — see the code repository._
/// ]
/// ```
///
/// - body (content): The slides-only content.
///
/// -> content
#let slides-only(body) = [#metadata((
  kind: "touying-slides-only",
  body: body,
))<touying-temporary-mark>]


/// Jump to a subslide position, either relatively or absolutely.
///
/// This is the unified core for both `#pause` and `#meanwhile`.
///
/// - When `relative: true` (relative mode): advances the subslide counter by `n`.
///   Positive `n` moves forward; negative `n` moves backward.
///   `n` must be a non-zero integer (zero would be a no-op with no visible effect).
///   `#pause` is equivalent to `#jump(1, relative: true)`.
///
/// - When `relative: false` (absolute mode, default): reveals all currently hidden
///   content and jumps to absolute subslide `n`.
///   `#meanwhile` is equivalent to `#jump(1)`.
///
/// Example:
///
/// ```typst
/// A #jump(1, relative: true) B   // same as A #pause B
/// A #jump(2, relative: true) C   // skip an extra subslide before C
/// A #pause B #jump(1) C          // C is always visible (same as #meanwhile)
/// A #pause B #jump(3) D          // D visible from subslide 3 onward
/// // A #pause B #pause C — normally C appears at subslide 3;
/// // adding #jump(-1, relative: true) before D makes D appear at subslide 2 (same as B):
/// A #pause B #pause C #jump(-1, relative: true) D
/// ```
///
/// - n (int): When `relative: true`, the number of subslides to advance (non-zero integer).
///   When `relative: false`, the absolute target subslide number (positive integer >= 1).
///
/// - relative (bool): If `true`, `n` is a relative offset from the current subslide counter.
///   If `false` (default), `n` is an absolute target subslide number.
///
/// -> content
#let jump(n, relative: false) = {
  if relative {
    assert(
      type(n) == int and n != 0,
      message: "jump: n must be a non-zero integer when relative: true, got "
        + repr(n),
    )
  } else {
    assert(
      type(n) == int and n >= 1,
      message: "jump: n must be a positive integer when relative: false, got "
        + repr(n),
    )
  }
  [#metadata((
    kind: "touying-jump/pause/meanwhile",
    n: n,
    relative: relative,
  ))<touying-temporary-mark>]
}


/// Reveal the next subslide. Inserts a subslide break: content after `#pause` appears one subslide later. Equivalent to `#jump(1, relative: true)`.
///
/// -> content
#let pause = jump(1, relative: true)


/// Reset the subslide counter back to 1, allowing content after `#meanwhile` to appear simultaneously with content from subslide 1. Equivalent to `#jump(1)`.
///
/// -> content
#let meanwhile = jump(1)


// Helper: check if a subslide spec string contains "h" (here marker)
// that needs deferred resolution to the current repetitions counter.
#let _has-here-marker(visible-subslides) = (
  type(visible-subslides) == str and visible-subslides.contains("h")
)

// Helper: create a last-subslide callback that resolves "h" in a string
// to the current repetitions counter at placement time.
#let _here-last-subslide(visible-subslides) = {
  repetitions => {
    let resolved = visible-subslides.replace("h", str(repetitions))
    (utils.last-required-subslide(resolved), (resolved-subslides: resolved))
  }
}


/// Take effect in some subslides.
///
/// Example: `#effect(text.with(fill: red), "2-")[Something]` will display `[Something]` if the current slide is 2 or later.
///
/// You can also add an abbreviation by using `#let effect-red = effect.with(text.with(fill: red))` for your own effects.
///
/// - fn (function): The function that will be called in the subslide.
///      Or you can use a method function like `(self: none) => { .. }`.
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - cont (content): The content to display when visible.
///
/// - is-method (bool): Whether the function is a method function. Default is `false`.
#let effect(fn, visible-subslides, cont, is-method: false) = {
  if visible-subslides == auto {
    // auto: resolve to current repetitions at placement time, no advance.
    touying-fn-wrapper(
      utils.effect,
      last-subslide: repetitions => (
        repetitions,
        (resolved-subslides: repetitions),
      ),
      fn,
      auto,
      is-method: is-method,
      cont,
    )
  } else if _has-here-marker(visible-subslides) {
    // "h" marker: deferred resolution of "h" to current repetitions.
    touying-fn-wrapper(
      utils.effect,
      last-subslide: _here-last-subslide(visible-subslides),
      fn,
      visible-subslides,
      is-method: is-method,
      cont,
    )
  } else {
    if type(visible-subslides) == label {
      [#metadata((
        kind: "touying-implicit-waypoint",
        label: str(visible-subslides),
      ))<touying-temporary-mark>]
    }
    touying-fn-wrapper(
      utils.effect,
      last-subslide: utils.last-required-subslide(visible-subslides),
      fn,
      visible-subslides,
      is-method: is-method,
      cont,
    )
  }
}


/// Uncover content in some subslides. Reserved space when hidden (like `#hide()`).
///
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #uncover("2-")[Only visible from subslide 2]
/// )
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - uncover-cont (content): The content to display when visible.
///
/// - cover-fn (function, auto): An optional cover function to use instead of the default cover method from the theme. Useful when using `uncover` inside external package integrations (e.g. `fletcher.hide` for fletcher diagrams).
///
/// -> content
#let uncover(visible-subslides, uncover-cont, cover-fn: auto) = {
  if visible-subslides == auto {
    // auto: resolve to current repetitions at placement time, no advance.
    touying-fn-wrapper(
      utils.uncover,
      last-subslide: repetitions => (
        repetitions,
        (resolved-subslides: repetitions),
      ),
      auto,
      uncover-cont,
      cover-fn: cover-fn,
    )
  } else if _has-here-marker(visible-subslides) {
    // "h" marker: deferred resolution of "h" to current repetitions.
    touying-fn-wrapper(
      utils.uncover,
      last-subslide: _here-last-subslide(visible-subslides),
      visible-subslides,
      uncover-cont,
      cover-fn: cover-fn,
    )
  } else {
    if type(visible-subslides) == label {
      [#metadata((
        kind: "touying-implicit-waypoint",
        label: str(visible-subslides),
      ))<touying-temporary-mark>]
    }
    touying-fn-wrapper(
      utils.uncover,
      last-subslide: utils.last-required-subslide(visible-subslides),
      visible-subslides,
      uncover-cont,
      cover-fn: cover-fn,
    )
  }
}


/// Display content in some subslides only. No space is reserved when hidden.
///
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #only("2")[Only on subslide 2]
/// )
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - only-cont (content): The content to display when visible.
///
/// -> content
#let only(visible-subslides, only-cont) = {
  if visible-subslides == auto {
    // auto: resolve to current repetitions at placement time, no advance.
    touying-fn-wrapper(
      utils.only,
      last-subslide: repetitions => (
        repetitions,
        (resolved-subslides: repetitions),
      ),
      auto,
      only-cont,
    )
  } else if _has-here-marker(visible-subslides) {
    // "h" marker: deferred resolution of "h" to current repetitions.
    touying-fn-wrapper(
      utils.only,
      last-subslide: _here-last-subslide(visible-subslides),
      visible-subslides,
      only-cont,
    )
  } else {
    if type(visible-subslides) == label {
      [#metadata((
        kind: "touying-implicit-waypoint",
        label: str(visible-subslides),
      ))<touying-temporary-mark>]
    }
    touying-fn-wrapper(
      utils.only,
      last-subslide: utils.last-required-subslide(visible-subslides),
      visible-subslides,
      only-cont,
    )
  }
}


/// `#alternatives` has a couple of "cousins" that might be more convenient in some situations. The first one is `#alternatives-match` that has a name inspired by match-statements in many functional programming languages. The idea is that you give it a dictionary mapping from subslides to content:
///
/// Example:
///
/// ```typst
/// #alternatives-match((
///   "1, 3-5": [this text has the majority],
///   "2, 6": [this is shown less often]
/// ))
/// ```
///
/// - subslides-contents (dictionary): A dictionary mapping from subslides to content.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-match(
  subslides-contents,
  position: bottom + left,
  stretch: false,
) = {
  // Validate: alternatives-match doesn't support waypoints, only numeric subslide specs
  let keys = if type(subslides-contents) == dictionary {
    subslides-contents.keys()
  } else {
    subslides-contents.map(kv => kv.at(0))
  }
  for key in keys {
    if type(key) == label {
      panic(
        "alternatives-match: waypoint labels are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
    if (
      type(key) == dictionary
        and "kind" in key
        and str(key.kind).starts-with("waypoint-")
    ) {
      panic(
        "alternatives-match: waypoint markers are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
  }
  touying-fn-wrapper(
    utils.alternatives-match,
    last-subslide: if type(subslides-contents) == dictionary {
      calc.max(..subslides-contents
        .pairs()
        .map(kv => utils.last-required-subslide(kv.at(0))))
    } else {
      calc.max(..subslides-contents.map(kv => utils.last-required-subslide(
        kv.at(0),
      )))
    },
    subslides-contents,
    position: position,
    stretch: stretch,
  )
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// You can also use waypoint labels via the `at` parameter:
///
/// ```typst
/// #alternatives(at: (<first>, <second>))[Content A][Content B]
/// ```
///
/// - start (int): The starting subslide number. Default is `auto`.
///
/// - repeat-last (bool): Whether the last alternative should persist on all remaining subslides. Default is `true`.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// - at (none | array): An array of waypoint labels (or waypoint markers like `get-first(<label>)`) or subslide specs, one per body.
///   When provided, each body is mapped to the corresponding waypoint range.
///   This is an alternative to the sequential `start`-based numbering.
///
/// -> content
#let alternatives(
  start: auto,
  repeat-last: true,
  position: bottom + left,
  stretch: false,
  at: none,
  ..args,
) = {
  if at != none {
    // Waypoint-based alternatives: map each label to its corresponding body
    let bodies = args.pos()
    assert(
      at.len() == bodies.len(),
      message: "alternatives: `at` array length ("
        + str(at.len())
        + ") must match number of bodies ("
        + str(bodies.len())
        + ")",
    )
    let subslides = at
    if repeat-last and subslides.len() > 0 {
      // Replace last entry with a from-wp() marker so it shows from that
      // waypoint onward (not just within its bounded range).
      let last-entry = subslides.last()
      subslides.at(-1) = if type(last-entry) == label {
        from-wp(last-entry)
      } else {
        last-entry
      }
    }
    let subslides-contents = subslides.zip(bodies)
    touying-fn-wrapper(
      utils.alternatives-match,
      last-subslide: calc.max(
        ..subslides.map(s => utils.last-required-subslide(s)),
      ),
      subslides-contents,
      position: position,
      stretch: stretch,
    )
  } else {
    let extra = if start == auto {
      (
        last-subslide: repetitions => (
          repetitions + args.pos().len() - 1,
          (start: repetitions),
        ),
      )
    } else {
      (
        last-subslide: start + args.pos().len() - 1,
      )
    }
    touying-fn-wrapper(
      utils.alternatives,
      start: start,
      repeat-last: repeat-last,
      position: position,
      stretch: stretch,
      ..extra,
      ..args,
    )
  }
}


/// You can have very fine-grained control over the content depending on the current subslide by using `#alternatives-fn`. It accepts a function (hence the name) that maps the current subslide index to some content.
///
/// Example: `#alternatives-fn(start: 2, count: 7, subslide => { numbering("(i)", subslide) })`
///
/// - start (int): The starting subslide number. Default is `1`.
///
/// - end (none, int): The ending subslide number. Default is `none`.
///
/// - count (none, int): The number of subslides. Default is `none`.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-fn(
  start: 1,
  end: none,
  count: none,
  position: bottom + left,
  stretch: false,
  ..kwargs,
  fn,
) = {
  // Validate integer parameters
  assert(
    type(start) == int,
    message: "alternatives-fn: start must be an integer, got "
      + str(type(start)),
  )
  if end != none {
    assert(
      type(end) == int,
      message: "alternatives-fn: end must be an integer or none, got "
        + str(type(end)),
    )
  }
  if count != none {
    assert(
      type(count) == int,
      message: "alternatives-fn: count must be an integer or none, got "
        + str(type(count)),
    )
  }
  let end = if end == none {
    if count == none {
      panic("You must specify either end or count.")
    } else {
      start + count
    }
  } else {
    end
  }
  touying-fn-wrapper(
    utils.alternatives-fn,
    last-subslide: end,
    start: start,
    end: end,
    count: count,
    position: position,
    stretch: stretch,
    ..kwargs,
    fn,
  )
}


/// You can use this function if you want to have one piece of content that changes only slightly depending of what "case" of subslides you are in.
///
/// Example:
///
/// ```typst
/// #alternatives-cases(("1, 3", "2"), case => [
///   #set text(fill: teal) if case == 1
///   Some text
/// ])
/// ```
///
/// - cases (array): An array of strings that specify the subslides for each case.
///
/// - fn (function): A function that maps the case to content. The argument `case` is the index of the cases array you input.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-cases(
  cases,
  fn,
  position: bottom + left,
  stretch: false,
  ..kwargs,
) = {
  // Validate: alternatives-cases doesn't support waypoints, only numeric subslide specs
  for case in cases {
    if type(case) == label {
      panic(
        "alternatives-cases: waypoint labels are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
    if (
      type(case) == dictionary
        and "kind" in case
        and str(case.kind).starts-with("waypoint-")
    ) {
      panic(
        "alternatives-cases: waypoint markers are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
  }
  touying-fn-wrapper(
    utils.alternatives-cases,
    last-subslide: calc.max(..cases.map(utils.last-required-subslide)),
    cases,
    fn,
    position: position,
    stretch: stretch,
    ..kwargs,
  )
}


/// Display list, enum, or terms items one by one with animation.
///
/// Each item is revealed on a successive subslide.  By default (`start: auto`),
/// revealing is relative to the current pause position — items appear one per
/// subslide starting from wherever the slide's animation has reached.
///
/// `start` also accepts a waypoint label (e.g. `<my-wp>`) or any waypoint
/// marker (`from-wp(<wp>)`, `get-first(<wp>)`, etc.) to anchor the reveal
/// sequence to a named position.
///
/// == Examples
///
/// ```typst
/// // Relative (auto) — items appear after any preceding #pause
/// #item-by-item[
///   - first
///   - second
///   - third
/// ]
///
/// // Anchored to a waypoint
/// #waypoint(<items>)
/// #item-by-item(start: <items>)[
///   - alpha
///   - beta
/// ]
///
/// // Explicit absolute subslide number (backward compatible)
/// #item-by-item(start: 3)[
///   - x
///   - y
/// ]
/// ```
///
/// - start (auto | int | label | dictionary): The subslide on which the first
///   item appears.  `auto` (default) makes it relative to the current pause
///   position.  An integer gives an absolute subslide number.  A label or
///   waypoint marker resolves to the waypoint's first subslide.
///
/// - cont (content): The content containing a list, enum, or terms element.
///
/// -> content
#let item-by-item(start: auto, cont) = {
  if (
    type(start) == dictionary
      and start.at("kind", default: none)
        in ("touying-waypoint-from", "touying-waypoint-until")
  ) {
    panic(
      "item-by-item: `start` must resolve to a single subslide position. "
        + "`from-wp` and `until-wp` are range markers and are not supported here. "
        + "Use a label, `get-first`, `get-last`, `prev-wp`, `next-wp` or simple slide numbers instead.",
    )
  }
  let num-items = if utils.is-sequence(cont) {
    cont
      .children
      .filter(c => (
        type(c) == content and c.func() in (list.item, enum.item, terms.item)
      ))
      .len()
  } else if cont.func() in (list, enum, terms) {
    cont.children.len()
  } else {
    1
  }
  if start == auto {
    // Relative: items start from the current pause position.
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: repetitions => (
        repetitions + num-items - 1,
        (start: repetitions),
      ),
      start: start,
      cont,
    )
  } else if type(start) == int {
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: start + num-items - 1,
      start: start,
      cont,
    )
  } else if type(start) == str {
    let parts = utils._parse-subslide-indices(start)
    if parts.len() != 1 or type(parts.first()) != int {
      panic(
        "item-by-item: `start` string must be a single number (e.g. \"3\"), "
          + "not a range or multi-value spec. Got: \""
          + start
          + "\".",
      )
    }
    let n = parts.first()
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: n + num-items - 1,
      start: n,
      cont,
    )
  } else {
    // Label or waypoint marker — resolved at render time.
    // For a plain label, emit an implicit waypoint so users don't need to write
    // a separate #waypoint(<label>) before the call.  The _waypoint-known check
    // in the prepass ensures the waypoint is only registered once even if an
    // explicit #waypoint(<label>) is also present.
    // Dictionary markers (from-wp, next-wp, get-first, …) reference an existing
    // explicit waypoint, so no implicit waypoint is needed for those.
    if type(start) == label {
      [#metadata((
        kind: "touying-implicit-waypoint",
        label: str(start),
      ))<touying-temporary-mark>]
    }
    // At callback time, `repetitions` equals the waypoint's subslide number
    // (the implicit or explicit waypoint was processed just before this wrapper).
    // We need num-items subslides starting from there, so the last subslide
    // needed is repetitions + num-items - 1.
    // Return empty extra-args so the original label/marker `start` is preserved
    // for render-time resolution via resolve-waypoints.
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: repetitions => (
        repetitions + num-items - 1,
        (:),
      ),
      start: start,
      cont,
    )
  }
}

/// Render a content block at a specific animation subslide.
/// Unlike `touying-block-recall` (./src/core/docmode.typ) which looks up a label, this takes a content
/// variable directly and renders it at the requested subslide index.
///
/// Example:
///
/// ```typ
/// #let ccanvas = touying-reducer(label: "doc-test-diagram", reduce: cetz.canvas, ...)
/// #ccanvas
///
/// #document-text[
///   Stage 2 of the canvas:
///   #touying-render(ccanvas, subslide: 2)
/// ]
/// ```
///
/// - body (content): The content to render. Can be a reducer metadata node
///   or any arbitrary content containing animation primitives.
///
/// - subslide (auto, int): Which animation stage to show.
///   - `auto` (default): the final / fully-revealed state (document mode)
///     or the current subslide (slide mode).
///   - `int`: a specific 1-indexed subslide number.
///
/// - base (auto, int): Starting repetition counter for pause numbering.
///   - `auto` (default): in slide mode, inherits the current slide's
///     repetition counter and waypoints; in document mode, resolves to `1`.
///   - `int`: explicit offset, e.g. `base: 3` makes the first pause
///     create subslide 4 instead of 2.
///
/// -> content
#let touying-render(body, subslide: auto, base: auto) = {
  [#metadata((
    kind: "touying-render",
    content: body,
    subslide: subslide,
    base: base,
  ))<touying-temporary-mark>]
}
