#import "../utils.typ"
#import "../extern.typ"
#import "tree.typ"
#import "subslides.typ": check-visible, resolve-negative-subslides
#import "waypoints.typ": (
  _compute-waypoint-ranges, _resolve-waypoint-forest, _waypoint-known,
  resolve-waypoints, waypoint-kinds,
)

/// The diagnostic for a touying mark that was never consumed.
///
/// There are two different answers, and which one applies turns on whether the
/// mark can name the function it came from. `#uncover` and friends can, and
/// for those `utils.uncover(self: self, ..)` computes in place rather than
/// leaving a mark behind. `#slides-only`, `#article-text` and `#slide` carry
/// an anonymous closure or nothing at all and have no callback form, so for
/// them the answer is where the mark sits, not how it is called.
///
/// - kind (str): The mark's `kind` field.
///
/// - fn (function, none): The function the mark came from, if it carries one.
///
/// - where (str): Where the mark was found, e.g. `"page 3 of the document"`.
///
/// -> str
#let unsupported-mark-message(kind, fn, where) = {
  // A named function reprs as its bare name; a closure as `(..) => ..`. Only
  // the former can be spelled back to the user as `utils.<name>`.
  let name = if fn == none { none } else { repr(fn) }
  let named = (
    name != none and name.match(regex("^[\\p{L}_][\\p{L}\\p{N}_-]*$")) != none
  )
  let head = (
    "Unsupported mark `"
      + kind
      + "`"
      + (if named { " from `" + name + "`" } else { "" })
      + " at "
      + where
      + ". "
  )
  if named {
    head + "Use the callback-style `utils." + name + "` instead."
  } else {
    (
      head
        + (
          "Touying resolves its marks before layout and never reached this one: "
            + "it is nested inside something the walk does not enter, such as a "
            + "`context` block or a measured container. Move it to the top level "
            + "of your document."
        )
    )
  }
}


/// Whether a mode marker's body belongs in this output mode.
///
/// - self (dictionary): The presentation context.
///
/// - value (dictionary): The marker's metadata value.
///
/// -> bool
#let mark-visible-in-mode(self, value) = {
  let article = self.at("article-mode", default: false)
  let kind = value.at("kind", default: none)
  if kind == "touying-slides-only" {
    let visible-in = value.at("visible-in", default: "slides")
    (
      not article
        and (
          visible-in == "slides"
            or (visible-in == "presentation" and not self.handout)
            or (visible-in == "handout" and self.handout)
        )
    )
  } else if kind in ("touying-article-only", "touying-article-text") {
    article
  } else {
    false
  }
}


/// Splice in the bodies of the mode markers that belong in this output, and
/// drop the ones that do not.
///
/// A `#slide[..]` call is meant to be optional, so content has to mean the
/// same thing with or without one. That means these markers cannot only be
/// resolved while walking the document: a slide captures its body in a
/// closure, and whatever is left inside it would otherwise survive to layout
/// time as an unconsumed mark.
///
/// - self (dictionary): The presentation context.
///
/// - body (any): The content to expand.
///
/// -> content
#let expand-mode-marks(self, body) = tree.map-tree(body, node => {
  // #article-linearize, #article-keep-layout and #graphic-marker each wrap
  // their body in a block tagged by an invisible metadata child. Only article
  // mode reads those tags, and neither the block nor the tag should reach a
  // reader's `query`, so in slide output the wrapper is unwrapped here and its
  // label moved onto what is left. Only the block's own children are dropped:
  // a nested marker keeps its tag until its own block is unwrapped.
  if (
    not self.at("article-mode", default: false)
      and type(node) == content
      and node.func() == block
  ) {
    let inner = node.at("body", default: none)
    let kids = if inner == none { () } else if tree.is-sequence(inner) {
      inner.children
    } else { (inner,) }
    let is-mark = k => (
      tree.is-kind(k, "touying-linearize")
        or tree.is-kind(k, "touying-graphic-marker")
    )
    if kids.any(is-mark) {
      let rest = kids.filter(k => not is-mark(k)).sum(default: [])
      return tree.relabel(
        expand-mode-marks(self, rest),
        node.at("label", default: none),
      )
    }
  }
  if tree.is-metadata(node) and type(node.value) == dictionary {
    let kind = node.value.at("kind", default: none)
    if kind in ("touying-slides-only", "touying-article-only") {
      if mark-visible-in-mode(self, node.value) {
        expand-mode-marks(self, node.value.body)
      } else {
        []
      }
    } else if (
      kind == "touying-article-text"
        and not mark-visible-in-mode(
          self,
          node.value,
        )
    ) {
      // In a slide deck there is nothing for the prose to stand in for.
      []
    }
  }
})


/// Every touying mark in `args`, in document order.
///
/// For the passes that only need to count repetitions and never cover or
/// render anything, so they can ignore the structure the marks sit in.
///
/// - args (array): The reducer call's positional arguments.
///
/// -> array
#let _flatten-reducer-args(args) = {
  let marks = ()
  let collect(node) = {
    if tree.is-touying-mark(node) { return (node,) }
    let kids = if type(node) == array { node } else { tree.children-of(node) }
    kids.map(collect).flatten()
  }
  for arg in args {
    marks += collect(arg)
  }
  marks
}


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
/// Whether a label should be attached on this subslide.
///
/// A slide body is parsed once per subslide, so content carrying a user label
/// would otherwise emit it on every rendered page, making `#ref` to it
/// ambiguous. `label-only-on-last-subslide` names the element functions that
/// hold their label back until the slide's last subslide.
///
/// - self (dictionary): The presentation context.
/// - func (function): The element function the label would land on.
///
/// -> bool
#let label-on-this-subslide(self, func) = {
  not (
    "repeat" in self
      and "subslide" in self
      and "label-only-on-last-subslide" in self
      and func in self.label-only-on-last-subslide
      and self.subslide != self.repeat
  )
}


/// Parse an external package's animated diagram and extract its repetitions.
///
/// Walks the elements handed to a reducer such as `cetz-canvas` or
/// `fletcher-diagram`, resolving the pause markers and fn-wrappers among them
/// and covering the rest with the package's own cover function.
///
/// Besides the drawn diagram and its repetition count, returns what the caller
/// needs to place the diagram on the right subslides:
///   - min-repetitions: the lowest the counter reached inside, which a
///     `#meanwhile` among the elements lowers and a later `#pause` hides again,
///   - has-fn-wrapper: whether any element sets its own visibility, by an
///     absolute subslide number or a waypoint.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - reducer (dictionary): The reducer metadata to parse
///
/// -> (array, int, int, bool)
#let _parse-touying-reducer(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  reducer,
) = {
  let parsed-results = ()
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
  let waypoints = self.at("waypoints", default: (:))
  // true if the node should only get its subslide at the end
  let held-back(node) = (
    type(node) == content
      and node.has("label")
      and node.label != <touying-temporary-mark>
      and not label-on-this-subslide(self, node.func())
  )
  let holds-back(node) = {
    if held-back(node) { return true }
    if type(node) == array { return node.any(holds-back) }
    if type(node) != content { return false }
    tree.children-of(node).any(holds-back)
  }

  // Walk `nodes` in order, carrying the animation state, and return the items
  // to hand on together with that state.
  //
  // The walk goes only as deep as the marks do, and puts every container back
  // together on the way out, so a package keeps whatever structure it was
  // handed: the array a code block joins its elements into, the sequence
  // algorithmic's `Assign` returns, the nested list algol reads as its
  // indentation. A node with no mark below it is a leaf, and that whole node
  // is what `cover` sees, because a cover function like `cetz.draw.hide` is
  // written for one of the package's own elements, not for its pieces.
  //
  // -> (array, int, int, int, int, bool)
  let visit(
    nodes,
    repetitions,
    max-repetitions,
    last-subslide,
    min-repetitions,
    has-fn-wrapper,
    wrap-leaf: false,
  ) = {
    let out = ()
    for child in nodes {
      if tree.is-touying-mark(child) {
        let kind = child.value.kind
        if kind == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            repetitions += child.value.n
            // Track the peak repetitions so that a subsequent negative jump
            // doesn't cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
          } else {
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = child.value.n
            last-subslide = 0
          }
          min-repetitions = calc.min(min-repetitions, repetitions)
        } else if kind == "touying-waypoint" {
          // Waypoint inside reducer: advance repetitions if applicable.
          // Only implicit/explicit waypoints supported, no waypoint markers.
          // Never pushed to the result.
          let lbl = child.value.label
          let wp-start = child.value.at("start", default: auto)
          if wp-start != auto and lbl in waypoints {
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = waypoints.at(lbl).first
            last-subslide = 0
            min-repetitions = calc.min(min-repetitions, repetitions)
          } else if (
            child.value.at("advance", default: true) and lbl in waypoints
          ) {
            let first = waypoints.at(lbl).first
            if first == repetitions + 1 {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
        } else if kind == "touying-implicit-waypoint" {
          // Implicit waypoint inside reducer: same firing logic as the outer
          // parser.
          let lbl = child.value.label
          if lbl in waypoints {
            let first = waypoints.at(lbl).first
            if first == repetitions + 1 {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
        } else if kind == "touying-fn-wrapper" {
          // Handle function wrappers (uncover, only, alternatives, etc.)
          // These always escape the pause zone: they handle their own
          // visibility.
          has-fn-wrapper = true
          let extra-args = (:)
          if child.value.last-subslide != none {
            let resolved = if type(child.value.last-subslide) == function {
              let (callback-last-subslide, callback-extra-args) = (
                child.value.last-subslide
              )(repetitions)
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
          // alternatives returning joined only() results) so the reduce
          // function sees the same flat items as it would in the callback
          // pathway.
          if fn-result != none {
            if type(fn-result) == array {
              out += fn-result
            } else if (
              type(fn-result) == content and tree.is-sequence(fn-result)
            ) {
              out += fn-result.children
            } else {
              out.push(fn-result)
            }
          }
        }
      } else if type(child) == array and tree.has-touying-mark(child) {
        // A code block joins the package's elements into one array, so this
        // array holds several elements and the marks between them. Its items
        // are visited with `wrap-leaf` set, because joining is what took each
        // element's own `array[1]` apart: `cetz.draw.hide` and alchemist's
        // `hide` both want that array back, not the bare item inside it.
        // The array itself is handed on, keeping the one-array shape a block
        // body's `reduce` expects.
        let (items, rep, maxrep, ls, inner-min, inner-fn-wrapper) = visit(
          child,
          repetitions,
          max-repetitions,
          last-subslide,
          min-repetitions,
          has-fn-wrapper,
          wrap-leaf: true,
        )
        repetitions = rep
        max-repetitions = maxrep
        last-subslide = ls
        min-repetitions = inner-min
        has-fn-wrapper = inner-fn-wrapper
        out.push(items)
      } else if (
        type(child) != array
          and (tree.has-touying-mark(child) or holds-back(child))
      ) {
        // A container with marks inside, or holding a label that this subslide
        // must not emit: visit its sub-content and put the container back
        // around the result, dropping its own label when it is held back.
        let (items, rep, maxrep, ls, inner-min, inner-fn-wrapper) = visit(
          tree.children-of(child),
          repetitions,
          max-repetitions,
          last-subslide,
          min-repetitions,
          has-fn-wrapper,
        )
        repetitions = rep
        max-repetitions = maxrep
        last-subslide = ls
        min-repetitions = inner-min
        has-fn-wrapper = inner-fn-wrapper
        out.push(tree.rebuild(child, items, labeled: not held-back(child)))
      } else if repetitions <= index or not need-cover {
        out.push(child)
      } else if wrap-leaf {
        // Inside a joined block the element was handed over re-wrapped, so a
        // cover that returns an array is returning elements to splice back
        // into the block, as `cetz.draw.hide` does.
        let r = cover((child,))
        if type(r) == array { out += r } else { out.push(r) }
      } else {
        // Elsewhere the element went in whole and comes back whole, even when
        // the element's own shape is an array, as algorithmic's is.
        out.push(cover(child))
      }
    }
    (
      out,
      repetitions,
      max-repetitions,
      last-subslide,
      min-repetitions,
      has-fn-wrapper,
    )
  }

  let (
    result,
    repetitions,
    max-repetitions,
    last-subslide,
    min-repetitions,
    has-fn-wrapper,
  ) = visit(reducer.args, base, base, 0, base, false)

  // Safety net: filter out any remaining touying metadata nodes before passing
  // to the external reduce function (e.g. fletcher.diagram, cetz.canvas).
  // All touying metadata should already be handled above — if this filter
  // catches anything, it indicates a bug in the reducer's metadata handling.
  let leaked = result.filter(tree.is-touying-mark)
  if leaked.len() > 0 {
    let kinds = leaked.map(c => c.value.at("kind", default: "unknown"))
    assert(
      false,
      message: "touying internal bug: leaked metadata into reducer result: "
        + repr(kinds)
        + ". Please report this at https://github.com/touying-typ/touying/issues",
    )
  }
  // Hand `reduce` back the shape the call site used: a body written as a code
  // block (`#cetz-canvas({ .. })`) arrives as one array argument and is passed
  // on as one array, while elements passed directly (`#lq-diagram(a, pause, b)`)
  // are spread again, for a `reduce` like `lq.diagram` that takes `..plots`.
  let drawn = (reducer.reduce)(..reducer.kwargs, ..result)
  // Article mode alone reads the mark, and it is the only mode where the
  // wrapper would not have to be taken out again afterwards.
  parsed-results.push(if self.at("article-mode", default: false) {
    block[#metadata((
        kind: "touying-graphic-marker",
        func: reducer.reduce,
      ))#drawn]
  } else { drawn })
  max-repetitions = calc.max(max-repetitions, repetitions)
  max-repetitions = calc.max(max-repetitions, last-subslide)
  return (
    parsed-results,
    max-repetitions,
    min-repetitions,
    has-fn-wrapper,
  )
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
    let flat-count-args = _flatten-reducer-args(value.args)
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
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
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
        let inner-flat-args = _flatten-reducer-args(child.value.args)
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
                inner-max = calc.max(inner-max, inner-rep, inner-ls)
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
      let kids = tree.children-of(child)
      if kids.len() > 0 {
        (
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        ) = _collect-waypoints-impl(
          kids,
          repetitions,
          last-subslide,
          waypoints,
          start-overrides,
          decl-reps,
        )
      }
    }
  }
  (repetitions, last-subslide, waypoints, start-overrides, decl-reps)
}



/// Collect all waypoint labels from slide bodies.
///
/// Returns `(raw-waypoints, start-overrides, decl-reps)`: `raw-waypoints` maps
/// label strings to the subslide numbers they sit on, `start-overrides` maps
/// labels with an explicit `start` to that spec (int or label string), and
/// `decl-reps` maps labels to a declared repeat count.
///
/// - base (int): The subslide the first position counts as. Positions come
///   back in that numbering, so a caller rendering from `render-base` gets
///   absolute numbers and never has to shift them afterwards.
///
/// - bodies (content): The content bodies to scan.
///
/// -> (dictionary, dictionary, dictionary)
#let _collect-waypoints(base: 1, ..bodies) = {
  let (_, _, waypoints, start-overrides, decl-reps) = _collect-waypoints-impl(
    bodies.pos(),
    base,
    0,
    (:),
    (:),
    (:),
  )
  (waypoints, start-overrides, decl-reps)
}



/// Link anchor naming the content a waypoint owns.
///
/// A waypoint marks a position in both time and space: the content that
/// belongs to it is everything from the marker up to the next waypoint, or to
/// the end of the body. The anchor therefore sits at the *end* of that run, so
/// a `#link` lands on the content the waypoint names rather than on a subslide
/// number. That position is well defined without subslides, which is what lets
/// article mode emit the same anchor.
///
/// A waypoint label is only unique within its slide, so the anchor joins the
/// enclosing slide's label with the waypoint's: `<intro>` + `<more>` gives
/// `<intro.more>`. Returns `none` for an unlabelled slide, so nothing is
/// emitted where no unique name exists.
///
/// - slide-label (label, none): The enclosing slide's label.
/// - wp-label (str): The waypoint's own label, already a string.
///
/// -> content or none
#let waypoint-anchor(
  slide-label,
  wp-label,
  wp-map: none,
  index: none,
  rendered: none,
) = {
  if slide-label == none {
    return none
  }
  // The parser walks the body once per subslide, so without this the anchor
  // would be emitted on every one of them and `#link` would resolve to the
  // first rather than to the waypoint's own content. `wp-map` is absent in
  // article mode, which renders the body once and needs no gate.
  if wp-map != none {
    let range = wp-map.at(wp-label, default: none)
    if range == none {
      return none
    }
    // Where the link anchor is injected:
    //   1. `range.last` itself, when it is rendered;
    //   2. otherwise the first rendered subslide after it — the content has
    //      fully revealed by then, so that page still carries it;
    //   3. otherwise only earlier subslides are rendered: take the last of
    //      them, and only if it is past where this waypoint begins, so a page
    //      showing none of its content gets no anchor.
    // `rendered: none` means every subslide is rendered, which makes (1) hold
    // trivially and leaves presentation mode on the `range.last` path.
    let target = if rendered == none {
      range.last
    } else {
      let at-or-after = rendered.filter(i => i >= range.last)
      if at-or-after != () {
        // Covers both (1) and (2): the minimum is `range.last` when rendered.
        at-or-after.first()
      } else if rendered != () and rendered.last() > range.first {
        rendered.last()
      } else {
        return none
      }
    }
    if index != target {
      return none
    }
  }
  // An empty labelled element, not `tree.label-it([], ..)`: a label on empty
  // content does not survive the walk, while one riding a `metadata` node does.
  [#metadata("touying-slide-waypoint-link-anchor")#label(
      str(slide-label) + "." + wp-label,
    )]
}


/// The enclosing slide's label, or `none` when it carries none.
///
/// -> label or none
#let slide-label-of(self) = {
  let headings = self.at("headings", default: ())
  if headings == () or not headings.last().has("label") {
    return none
  }
  headings.last().label
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
    eqt-metadata.has("label")
      and eqt-metadata.label != <touying-temporary-mark>
      and label-on-this-subslide(self, math.equation)
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
    eqt-metadata.has("label")
      and eqt-metadata.label != <touying-temporary-mark>
      and label-on-this-subslide(self, math.equation)
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
    raw-metadata.has("label")
      and raw-metadata.label != <touying-temporary-mark>
      and label-on-this-subslide(self, raw)
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
  let resolved = resolve-waypoints(self, spec)
  if type(resolved) == int {
    resolved
  } else if type(resolved) == dictionary {
    resolved.at("beginning", default: resolved.at("first", default: 1))
  } else {
    panic("unexpected resolved waypoint type: " + repr(resolved))
  }
}

/// Every subslide index in `[lo, hi]` that `check-visible` accepts
/// `spec` for. `check-visible` already understands every dict/string shape
/// `subslides:` can resolve to (`(beginning:, until:)`, `(kind: "not",
/// inner:)`, `"2-4"`, `"!2-4"`, ...), so this is the one shared primitive
/// both waypoint- and string-based member resolution below build on.
///
/// -> array (sorted, ascending)
#let _members-in-range(spec, lo, hi) = (
  range(lo, hi + 1).filter(idx => check-visible(idx, spec))
)

/// Resolve a waypoint label or dictionary marker to the full, sorted set of
/// subslide indices it captures — unlike `_resolve-waypoint-to-int`, which
/// collapses a range down to its first ("beginning") value alone. A
/// single-subslide marker (`get-first`, `get-last`, ...) still comes back
/// as a one-element list, so callers never need to special-case cardinality.
///
/// - self (dictionary): carries the `waypoints` map `spec` is resolved against.
/// - spec (label, dictionary): the waypoint reference to resolve.
/// - bound (int): Upper bound used to enumerate the members of a negated
///   (`not-wp`) marker, whose own range is unbounded above.
/// - base (int): Lower bound, for content whose own numbering starts above 1.
///
/// -> array (sorted, ascending, non-empty)
#let _resolve-waypoint-to-members(self, spec, bound, base: 1) = {
  let resolved = resolve-waypoints(self, spec)
  if type(resolved) == int {
    (resolved,)
  } else {
    _members-in-range(resolved, base, bound)
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
  let labeled(func) = label-on-this-subslide(self, func)
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
    let probe-reducer-data = if tree.is-kind(child, "touying-reducer") {
      child.value
    }
    let (raw-wp, so, dr) = _collect-waypoints(child)
    let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
    // A waypoint reference must already resolve while probing, so probe
    // against the positions the static walk knows rather than an empty map.
    let provisional-cwp = _compute-waypoint-ranges(
      resolved-wp,
      calc.max(..resolved-wp.values(), 1),
      so,
      dr,
    )
    let max-rep-raw = if probe-reducer-data != none {
      let (_, mrr, ..) = _parse-touying-reducer(
        self: self + (waypoints: provisional-cwp, subslide: 9999),
        base: 1,
        index: 9999,
        probe-reducer-data,
      )
      mrr
    } else {
      let (_, mrr, ls, ..) = _parse-content-into-results-and-repetitions(
        self: self + (waypoints: provisional-cwp, subslide: 9999),
        base: 1,
        index: 9999,
        child,
      )
      calc.max(mrr, ls)
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
        let reducer-data = if tree.is-kind(raw-content, "touying-reducer") {
          raw-content.value
        }
        let (raw-wp, so, dr) = _collect-waypoints(
          base: render-base,
          raw-content,
        )
        let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
        // A waypoint reference must already resolve while probing, so probe
        // against the positions the static walk knows rather than an empty map.
        let provisional-cwp = _compute-waypoint-ranges(
          resolved-wp,
          calc.max(render-base, ..resolved-wp.values(), 1),
          so,
          dr,
        )
        let max-rep-raw = if reducer-data != none {
          let (_, mrr, ..) = _parse-touying-reducer(
            self: minimal-self + (waypoints: provisional-cwp, subslide: 9999),
            base: render-base,
            index: 9999,
            reducer-data,
          )
          mrr
        } else {
          let (_, mrr, ls, ..) = _parse-content-into-results-and-repetitions(
            self: minimal-self + (waypoints: provisional-cwp, subslide: 9999),
            base: render-base,
            index: 9999,
            raw-content,
          )
          calc.max(mrr, ls)
        }
        let repeat = calc.max(
          max-rep-raw,
          render-base,
          ..resolved-wp.values(),
          1,
        )
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
          // The map was collected from `render-base`, so it already uses the
          // same absolute numbering as `repeat`.
          _resolve-waypoint-to-int((waypoints: cwp), recall-subslide)
        } else {
          // `repeat` is the absolute final index, so convert it to a plain
          // stage count before resolving negative indices against `base`.
          resolve-negative-subslides(
            repeat - render-base + 1,
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
          let (r, ..) = _parse-touying-reducer(
            self: render-self,
            base: render-base,
            index: target,
            reducer-data,
          )
          r.sum(default: none)
        } else {
          let (conts, ..) = _parse-content-into-results-and-repetitions(
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
  // Parse a container's sub-content and rebuild the container around it.
  //
  // `body-field` names where the sub-content lives: "children" spreads several
  // (table, grid, stack), anything else is one body, and "body-or-none"
  // tolerates its absence.
  //
  // Returns a 6-tuple:
  //   - reconstructed-content: the reconstructed container content
  //   - max-repetitions: maximum repetitions found inside the content
  //   - next-last-subslide: maximum last-subslide of any fn-wrappers found (0 if none)
  //   - final-repetitions: repetitions count after processing all inner content
  //   - force-to-result: true when fn-wrappers were found inside a pause zone and the
  //       returned `reconstructed-content` was produced with proper inner covering;
  //       the caller MUST push this content directly to `result` (not `hidden-parts`).
  //   - inner-has-fn-wrapper: whether a fn-wrapper was found at all. A wrapper
  //       decides its own visibility, so an enclosing container has to know one
  //       is in there even when this level did not have to force anything.
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
    // A table-like element holds its sub-content as several children rather
    // than one body, so it is parsed by spreading them and rebuilt from the
    // whole array. Everything else parses one body and rebuilds from one.
    // "tree" defers to `tree.children-of`, which knows where each shape keeps
    // its sub-content — including the math elements that hold theirs in named
    // fields of their own (`frac`'s num/denom, `mat`'s rows, `attach`'s
    // scripts). Like "children" it spreads, and `tree.rebuild` puts the shape
    // back, so one mode covers all of them.
    let spread = body-field in ("children", "tree")
    let body-content = if body-field == "tree" {
      tree.children-of(child)
    } else if body-field == "children" {
      child.children
    } else if body-field == "body-or-none" {
      (child.at("body", default: none),)
    } else {
      (child.at(body-field),)
    }
    let (
      conts,
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
      inner-has-fn-wrapper,
      inner-min-repetitions,
    ) = _parse-content-into-results-and-repetitions(
      self: self,
      need-cover: repetitions <= index,
      base: repetitions,
      base-last-subslide: last-subslide,
      index: index,
      ..body-content,
    )
    let cont = if spread { conts } else { conts.first() }
    // Two-pass: if fn-wrappers are present inside a pause zone, re-run the inner parse
    // with the outer need-cover so that fn-wrappers handle their own visibility and
    // non-fn-wrapper content is properly covered by the inner mechanism.
    // `inner-min-repetitions` is the lowest the counter reached inside, which
    // `final-repetitions` cannot show: a `#meanwhile` rewinds it to run beside
    // what came before, and a later `#pause` winds it forward again.
    let would-be-hidden = not (
      calc.min(repetitions, final-repetitions) <= index or not need-cover
    )
    // A `#meanwhile` inside rewound the counter far enough to put part of this
    // body on the current subslide, even though the body neither starts nor
    // ends there. Only the minimum shows that: a rewind that a later `#pause`
    // winds forward again leaves the end value identical to no rewind at all.
    let meanwhile-dips-visible = (
      would-be-hidden and inner-min-repetitions <= index
    )
    if would-be-hidden and (inner-has-fn-wrapper or meanwhile-dips-visible) {
      let (
        conts2,
        inner-max-repetitions2,
        ..,
      ) = _parse-content-into-results-and-repetitions(
        self: self,
        need-cover: need-cover,
        base: repetitions,
        base-last-subslide: last-subslide,
        index: index,
        ..body-content,
      )
      let cont2 = if spread { conts2 } else { conts2.first() }
      return (
        reconstruct-fn(child, cont2),
        inner-max-repetitions2,
        next-last-subslide,
        final-repetitions,
        true,
        inner-has-fn-wrapper,
        inner-min-repetitions,
      )
    }
    return (
      reconstruct-fn(child, cont),
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
      false,
      inner-has-fn-wrapper,
      inner-min-repetitions,
    )
  }
  // Content function sets for different handling categories
  let list-item-functions = (list.item, enum.item, align, link)
  let table-like-functions = (table, grid, stack)
  let reconstructable-functions = (
    pad,
    figure,
    figure.caption,
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
    heading,
    columns,
    place,
    rotate,
    math.equation,
    // Math containers whose sub-content is a plain body or children. The
    // named-field ones (frac, mat, attach, ...) take the `tree.shape-of`
    // branch above instead.
    math.lr,
    math.abs,
    math.norm,
    math.floor,
    math.ceil,
    math.round,
    math.cancel,
    math.scripts,
    math.limits,
    math.upright,
    math.italic,
    math.bold,
    math.display,
    math.inline,
    math.script,
    math.sscript,
  )
  let bodies = bodies.pos()
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // The lowest the counter reaches anywhere in this parse. `repetitions` on
  // its own reports where the parse ended, which cannot show a `#meanwhile`
  // that rewound and was then wound forward again by a later `#pause`; a
  // caller deciding whether any of this content is on the current subslide
  // needs the dip, not the end.
  let min-repetitions = repetitions
  // last-subslide by touying-fn-wrapper — inherit outer context so waypoints
  // placed after multi-subslide fn-wrappers fire correctly inside sub-sequences.
  let last-subslide = base-last-subslide
  // Whether any touying-fn-wrapper was found in this parse (directly or via
  // recursive calls).  Used by the two-pass escape hatch so that fn-wrappers
  // inside a pause zone can handle their own visibility.
  let has-fn-wrapper = false
  // The waypoint whose content run is still open, so its link anchor can be
  // emitted at the *end* of that run: when the next waypoint starts, or after
  // the loop when none follows. See `waypoint-anchor`.
  let open-waypoint = none
  let slide-label = slide-label-of(self)
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  // the cover method applied to a figure to cover its caption with supplement and numbering when it should be fully covered.
  let cover-caption = if (
    utils.cover-kind(self.methods.cover) == "recolour"
  ) {
    self.methods.cover.with(self: utils.cover-caption-query)
  } else {
    it => {
      show figure.caption: _cap => cover(_cap)
      it
    }
  }

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
            min-repetitions = calc.min(min-repetitions, repetitions)
          } else {
            // absolute jump
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = it.body.value.n
            min-repetitions = calc.min(min-repetitions, repetitions)
            last-subslide = 0
          }
          continue
        } else if kind == "touying-waypoint" {
          let wp = self.at("waypoints", default: (:))
          let lbl = it.body.value.label
          let wp-start = it.body.value.at("start", default: auto)
          if wp-start != auto and lbl in wp {
            // Explicit start: absolute jump to the resolved position.
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = wp.at(lbl).first
            min-repetitions = calc.min(min-repetitions, repetitions)
            last-subslide = 0
          } else if it.body.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 {
              repetitions = first
              min-repetitions = calc.min(min-repetitions, repetitions)
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
              min-repetitions = calc.min(min-repetitions, repetitions)
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

    // -------------------------------------
    //   Covering lists of items without moving rows
    //
    //   Covering part of an item run costs the container the rows those items
    //   occupied, and its wider pitch when a parbreak had made it non-tight.
    //   `item-by-item-fn` in `utils.typ` corrects the same two.
    // -------------------------------------

    // The gap bordering a covered run next to the item `it`, or paragraph
    // spacing when `it` is not an item.
    //
    // Only the `nontight-list-enum-and-terms` config is touying's own; it makes
    // every container non-tight and so decides the `auto` fallback.
    let get-spacing-bordering(it, nontight: false) = {
      if not tree.is-list-like-item(it) {
        return par.spacing
      }
      tree.get-row-spacing-of-list-like(
        it.func(),
        tight: not (
          nontight or self.at("nontight-list-enum-and-terms", default: true)
        ),
      )
    }

    // Rewrite the run of visible items that `result` ends in as an explicitly
    // non-tight container.
    //
    // Covering the run after the parbreak leaves the parbreak separating
    // nothing, so the remaining items revert to tight and every visible row
    // moves. A block after a container cannot move it, so the tightness has to
    // be asserted on the visible items themselves.
    //
    // `parbreak-is-visible` says which side of the boundary the parbreak fell:
    // - before it, it is this run's last element and is held aside,
    // - past it, it is among the covered items and the run ends at the tail.
    let rebuild-visible-tail-nontight(result, parbreak-is-visible: true) = {
      // Trailing spaces are not part of the run and are put back untouched.
      let content-end = result.len()
      while content-end > 0 and tree.is-space(result.at(content-end - 1)) {
        content-end -= 1
      }
      if content-end == 0 { return result }

      // Nothing to do when the parbreak was expected here but is not.
      if (
        parbreak-is-visible and not tree.is-parbreak(result.at(content-end - 1))
      ) {
        return result
      }

      // The held-aside parbreak, if it is on this side, plus those spaces.
      let run-end = if parbreak-is-visible { content-end - 1 } else {
        content-end
      }
      let kept-tail = result.slice(run-end)

      // A covered run emitted earlier stands in for items of this same
      // container, so it is the one non-item element that does not end it.
      // `cover-hidden` wraps it in a `context` block.
      let run = tree.get-list-like-run-ending-at(
        result,
        run-end,
        opaque: el-func => el-func == tree.typst-builtin-context,
      )

      // A container of one item has no tightness to preserve.
      if run.items.len() < 2 { return result }

      (
        result.slice(0, run.start)
          + (tree.build-list-like-from(run.items, tight: false),)
          + kept-tail
      )
    }

    // The covered items as the body to hand to the cover method.
    //
    // The reserved rows include the gaps between the covered items. Covered as
    // a bare sequence they lay out tight and reserve too little, so a non-tight
    // run is rebuilt as its own container.
    let build-covered-body(items, is-nontight) = {
      // A trailing mark or metadata follows the container rather than belonging
      // to it, so the scan ends just past the last item.
      let steps-back = items.rev().position(tree.is-list-like-item)
      if steps-back == none { return items.sum() }

      let run-end = items.len() - steps-back
      let run = tree.get-list-like-run-ending-at(items, run-end)
      if not is-nontight or run.items.len() < 2 { return items.sum() }

      (
        items.slice(0, run.start).sum(default: [])
          + tree.build-list-like-from(run.items, tight: false)
          + items.slice(run-end).sum(default: [])
      )
    }

    /// Cover a run of hidden elements, correcting the container spacing it
    /// would otherwise cost.
    ///
    /// Returns `(result, covered)`:
    /// - `result` is `last-result`, rewritten when the covered run forces the
    ///   visible items before it to stay non-tight,
    /// - `covered` is the content to append after it.
    ///
    /// `next-is-list` and `rest` are look-ahead the caller supplies, since a
    /// `#pause` splits one container across several calls.
    let cover-hidden(
      cover-fn,
      items,
      last-result,
      next-is-list: false,
      rest: (),
    ) = {
      // The elements bordering the gaps above and below the block. Only spaces
      // are skipped: a parbreak or linebreak there is the user breaking the
      // container deliberately, which the decisions below have to see.
      let first-hidden = tree.find-first-non-space(items)
      let last-hidden-item = tree.find-last-non-space(items)
      let last-visible-item = tree.find-last-non-space(last-result)

      // A gap only needs correcting where items sit on both of its sides.
      let first-hidden-is-item = tree.is-list-like-item(first-hidden)
      let last-hidden-is-item = tree.is-list-like-item(last-hidden-item)
      let last-visible-is-item = tree.is-list-like-item(last-visible-item)

      // Would Typst have built one non-tight container across this boundary?
      // A parbreak widens the container its items form, and that pitch applies
      // to every row on both sides. Items of different kinds are separate
      // containers regardless, so a parbreak between those changes nothing.
      //
      // The parbreak can fall on either side, so the question is asked of the
      // visible tail and the covered items together, as the source had them.
      let visible-run = tree.get-list-like-run-ending-at(
        last-result,
        last-result.len(),
      )
      // `rest` is what follows the cover, which a later `#pause` has not yet
      // reached but which still belongs to the same container.
      let span = last-result.slice(visible-run.start) + items + rest
      let list-is-nontight = tree.contains-nontight-list-like(span)
      let covered = cover-fn(build-covered-body(items, list-is-nontight))
      // A gap needs a reserved row only where items sit on both sides:
      // - above, a container interrupted by a `#pause`,
      // - below, a `#meanwhile` revealing further items after the cover.
      //
      // Each side is decided on its own; anything else keeps `auto` spacing.
      let gap-above-needs-row = first-hidden-is-item and last-visible-is-item
      let gap-below-needs-row = last-hidden-is-item and next-is-list

      // Items of different kinds are two containers, separated by paragraph
      // spacing rather than a row gap.
      let opens-new-container = (
        gap-above-needs-row and first-hidden.func() != last-visible-item.func()
      )
      // Covering one side of a non-tight container would let the other revert
      // to tight, so the visible run is re-emitted as an explicit container.
      let result = if first-hidden-is-item and list-is-nontight {
        rebuild-visible-tail-nontight(
          last-result,
          parbreak-is-visible: tree.is-parbreak(last-visible-item),
        )
      } else {
        last-result
      }
      let covered = if gap-above-needs-row or gap-below-needs-row {
        context block(
          above: if opens-new-container {
            par.spacing
          } else if gap-above-needs-row {
            get-spacing-bordering(first-hidden, nontight: list-is-nontight)
          } else {
            auto
          },
          below: if gap-below-needs-row {
            get-spacing-bordering(last-hidden-item, nontight: list-is-nontight)
          } else {
            auto
          },
          covered,
        )
      } else {
        covered
      }
      (result: result, covered: covered)
    }

    // Flatten sequences and handle each child element
    let children = if tree.is-sequence(it) {
      it.children
    } else {
      (it,)
    }

    // -------------------------------------
    //   Looking ahead for the rest of a container
    //
    //   A `#pause` splits one container across several `cover-hidden` calls, so
    //   what follows the cover has to be read off `children`.
    // -------------------------------------

    // Is the first sibling after `from-index` an item? A covered run needs a
    // gap reserved below it only then, as after a `#meanwhile`.
    //
    // Only spaces are stepped over, so a parbreak or linebreak yields false.
    let next-sibling-is-item(from-index) = {
      let index = from-index + 1
      while index < children.len() {
        let sibling = children.at(index)
        if not tree.is-space(sibling) {
          return tree.is-list-like-item(sibling)
        }
        index += 1
      }
      false
    }

    // The rest of the container after `from-index`. A parbreak further down
    // still widens the whole container, so a call seeing only the items before
    // it would reserve the tight pitch.
    let get-list-continuation-after(from-index, kind) = {
      let continuation = ()
      let index = from-index + 1
      while index < children.len() {
        let sibling = children.at(index)
        let belongs = (
          tree.is-space(sibling)
            or tree.is-parbreak(sibling)
            or (tree.is-list-like-item(sibling) and sibling.func() == kind)
        )
        if not belongs { break }
        continuation.push(sibling)
        index += 1
      }
      continuation
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
            min-repetitions = calc.min(min-repetitions, repetitions)
            // Track the peak repetitions so that a subsequent negative jump doesn't
            // cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
            // If we jumped back into the visible zone, flush hidden-parts in order
            // (so they appear before subsequent visible content, not after it)
            if hidden-parts.len() != 0 and repetitions <= index {
              {
                let covered = cover-hidden(
                  cover,
                  hidden-parts,
                  result,
                  next-is-list: next-sibling-is-item(_child_i),
                )
                result = covered.result
                result.push(covered.covered)
              }
              hidden-parts = ()
            }
          } else {
            // absolute: reveal all hidden content then jump to target subslide.
            // Visible content (e.g. list items) may follow directly, so look
            // ahead to correct the spacing below the covered run.
            if hidden-parts.len() != 0 {
              {
                let covered = cover-hidden(
                  cover,
                  hidden-parts,
                  result,
                  next-is-list: next-sibling-is-item(_child_i),
                )
                result = covered.result
                result.push(covered.covered)
              }
              hidden-parts = ()
            }
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = child.value.n
            min-repetitions = calc.min(min-repetitions, repetitions)
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
          min-repetitions = calc.min(min-repetitions, repetitions)
        } else if kind == "touying-reducer" {
          // Handle external package reducers (CeTZ, Fletcher) with animations
          // The elements decide their own visibility whenever one of them
          // carries an absolute subslide number or a waypoint, so the walk
          // covers them individually and the diagram is built on every
          // subslide. Without such an element it animates by the flow alone,
          // and the counter it inherited is what places it.
          let (
            conts,
            nextrepetitions,
            inner-min-repetitions,
            inner-has-fn-wrapper,
          ) = _parse-touying-reducer(
            self: self,
            need-cover: need-cover,
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
              and label-on-this-subslide(self, tree.typst-builtin-context)
          ) {
            [#block(cont)#real-label]
          } else {
            cont
          }
          if (
            calc.min(repetitions, inner-min-repetitions) <= index
              or inner-has-fn-wrapper
              or not need-cover
          ) {
            result.push(cont)
          } else {
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
          min-repetitions = calc.min(
            min-repetitions,
            repetitions,
            inner-min-repetitions,
          )
        } else if kind == "touying-render" {
          // Render inline content at a specific subslide.
          // In slide mode, default (auto) renders at the current slide index.
          let inline-content = child.value.content
          let subslides-spec = child.value.subslides
          let use-slide-context = child.value.at("base", default: auto) == auto
          // A waypoint marker names a waypoint of the body it selects a stage
          // from, as it does for `touying-recall`. Aiming at the enclosing
          // slide's map instead is opt-in per call, and article mode has no
          // enclosing progression to aim at in the first place.
          let use-outer-waypoints = (
            use-slide-context
              and child.value.at("use-outer-waypoints", default: false)
              and not self.at("article-mode", default: false)
          )
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
          // Pushed rather than emitted here: this function ends in an explicit
          // `return`, which discards whatever the walk joined along the way.
          let inert-anchor-warning = if (
            self.at("article-mode", default: false)
              and (start-spec != auto or repeat-last-spec != true)
          ) {
            start-spec = auto
            repeat-last-spec = true
            extern.warning(
              "touying-render: start:/repeat-last: have no effect in "
                + "article mode (there is no subslide progression to gate "
                + "against). Wrap this call in #slides-only[...] to "
                + "suppress this warning once you've confirmed that's what "
                + "you want.",
            )
          }
          if inert-anchor-warning != none {
            result.push(inert-anchor-warning)
          }
          // Compute render context (inlined from _prepare-render-context)
          let reducer-data = if tree.is-kind(
            inline-content,
            "touying-reducer",
          ) {
            inline-content.value
          }
          let (raw-wp, so, dr) = _collect-waypoints(
            base: render-base,
            inline-content,
          )
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
            let (_, mrr, ..) = _parse-touying-reducer(
              self: self + (waypoints: wp, subslide: 9999),
              base: render-base,
              index: 9999,
              reducer-data,
            )
            mrr
          } else {
            let (_, mrr, ls, ..) = _parse-content-into-results-and-repetitions(
              self: self + (waypoints: wp, subslide: 9999),
              base: render-base,
              index: 9999,
              inline-content,
            )
            calc.max(mrr, ls)
          }
          // A reference to a waypoint has to resolve during the probe itself,
          // so the probe runs against a provisional map built from the static
          // walk's own start positions. The probe then supplies the repeat
          // bound the final ranges are closed against.
          let provisional-cwp = _compute-waypoint-ranges(
            resolved-wp,
            calc.max(render-base, ..resolved-wp.values(), 1),
            so,
            dr,
          )
          let content-mrr = probe(provisional-cwp)
          let content-repeat = calc.max(
            content-mrr,
            render-base,
            ..resolved-wp.values(),
            1,
          )
          let content-cwp = _compute-waypoint-ranges(
            resolved-wp,
            content-repeat,
            so,
            dr,
          )
          // Target resolution uses the content's own waypoints unless the
          // call opted into the enclosing slide's with `use-outer-waypoints`.
          // The repeat bound is always the content's own repeat count
          // (`content-repeat`, already computed with `render-base` baked in
          // via `_parse-touying-reducer`/`_parse-content-into-results-and-repetitions`
          // above) — `self.repeat` is the *enclosing slide's* pause count,
          // which is unrelated to how many stages this rendered content has.
          let cwp = if use-outer-waypoints {
            self.at("waypoints", default: (:))
          } else {
            content-cwp
          }
          let rp = content-repeat
          // start: always resolves against the *outer* slide's own waypoints
          // (self.waypoints), since it anchors this content into the outer
          // numbering. That is a separate lookup from cwp above, which
          // resolves subslide: against the content's own waypoints.
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
          // indices (collected from `render-base`, matching `rp`'s own
          // convention) — a single-point spec (a plain int, `get-first`,
          // `get-last`, ...) simply comes back as a one-element list, so
          // the stepping logic just below needs no cardinality special
          // case: `auto` + `start:` steps through this content's *entire*
          // natural range (reframed as the identity member list
          // `render-base..content-repeat` instead of a bespoke clamp
          // formula), and an explicit range/waypoint/string spec steps
          // through whatever subset it captures.
          let targets = if is-bare-auto {
            () // unused; is-bare-auto short-circuits before this is read
          } else if subslides-spec == auto {
            range(render-base, content-repeat + 1)
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
              // Both maps already use absolute positions. A `not-wp` marker
              // over the outer map must enumerate the outer slide's repeat
              // count; one over the content's own map starts at `render-base`.
              let bound = if use-outer-waypoints {
                self.at("repeat", default: content-repeat)
              } else {
                content-repeat
              }
              _resolve-waypoint-to-members(
                wp-self,
                spec,
                bound,
                base: if use-outer-waypoints { 1 } else { render-base },
              )
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
                resolve-negative-subslides(
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
            let (r, ..) = _parse-touying-reducer(
              self: render-self,
              base: render-base,
              index: target,
              reducer-data,
            )
            r.sum(default: none)
          } else {
            let (conts, ..) = _parse-content-into-results-and-repetitions(
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
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
            hidden-parts = ()
          }
          result.push((child.value.fn)(
            self: self,
            ..pos-args,
            ..child.value.args.named(),
            ..extra-args,
          ))
          repetitions = nextrepetitions
          min-repetitions = calc.min(min-repetitions, repetitions)
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
            inner-min-repetitions,
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
              {
                let covered = cover-hidden(cover, hidden-parts, result)
                result = covered.result
                result.push(covered.covered)
              }
              hidden-parts = ()
            }
            max-repetitions = calc.max(max-repetitions, repetitions)
          }
          // The end value cannot show a `#meanwhile` that a later `#pause` wound
          // forward again, so the two-pass also triggers on the minimum reached
          // inside. This only re-parses the body so it covers itself per mark;
          // `would-be-hidden` still uses the entry repetitions, so no content
          // before the rewind is revealed.
          let meanwhile-dips-visible = (
            would-be-hidden and inner-min-repetitions <= index
          )
          if (
            would-be-hidden
              and (
                inner-has-fn-wrapper
                  or meanwhile-escaped
                  or meanwhile-dips-visible
              )
          ) {
            // Two-pass: the body has to decide its own visibility, so re-run it
            // with the outer need-cover and push to result rather than
            // hidden-parts. A fn-wrapper directly inside a hidden wrapper would
            // otherwise be covered twice; a #meanwhile needs the inner parse to
            // cover what comes before it while revealing what comes after.
            let (
              conts2,
              inner-max-repetitions2,
              ..,
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
          min-repetitions = calc.min(min-repetitions, repetitions)
          min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
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
            ..,
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
            max-repetitions = calc.max(
              max-repetitions,
              repetitions,
              last-subslide,
            )
            repetitions = wp.at(lbl).first
            min-repetitions = calc.min(min-repetitions, repetitions)
            last-subslide = 0
          } else if child.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 {
              repetitions = first
              min-repetitions = calc.min(min-repetitions, repetitions)
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output of its own. The previous waypoint's run ends
          // here, so its anchor lands before this one's content begins.
          if open-waypoint != none {
            result.push(waypoint-anchor(
              slide-label,
              open-waypoint,
              wp-map: wp,
              index: index,
              rendered: self.at("rendered-subslides", default: none),
            ))
          }
          open-waypoint = lbl
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
              min-repetitions = calc.min(min-repetitions, repetitions)
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
          {
            // This parbreak may be the one that makes the container
            // non-tight, and the items it applies to are still ahead, so hand
            // them over along with the parbreak itself.
            let hidden-run = tree.get-list-like-run-ending-at(
              hidden-parts,
              hidden-parts.len(),
            )
            let covered = cover-hidden(
              cover,
              hidden-parts,
              result,
              rest: if hidden-run.kind == none { () } else {
                (
                  (child,)
                    + get-list-continuation-after(
                      _child_i,
                      hidden-run.kind,
                    )
                )
              },
            )
            result = covered.result
            result.push(covered.covered)
          }
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
          inner-min-repetitions,
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
        // As in `parse-and-reconstruct`: a `#meanwhile` inside may have rewound
        // far enough to put part of this sequence on the current subslide even
        // though it neither starts nor ends there, which only the minimum shows.
        let meanwhile-dips-visible = (
          would-be-hidden and inner-min-repetitions <= index
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and (inner-has-fn-wrapper or meanwhile-dips-visible)
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            ..,
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
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and (inner-has-fn-wrapper or meanwhile-dips-visible)
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(cont)
        } else {
          hidden-parts.push(cont)
        }
        repetitions = final-repetitions
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if tree.is-styled(child) {
        // handle styled
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
          inner-has-fn-wrapper,
          inner-min-repetitions,
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
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
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
          inner-has-fn-wrapper,
          inner-min-repetitions,
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
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
      } else if (
        type(child) == content and child.func() in table-like-functions
      ) {
        // handle the table-like
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
          inner-has-fn-wrapper,
          inner-min-repetitions,
        ) = parse-and-reconstruct(
          self,
          child,
          "children",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, conts) => tree.reconstruct-table-like(
            child,
            labeled: labeled(child.func()),
            conts,
          ),
        )
        // Propagate meanwhile effect from inside the table/grid/stack
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
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
              // `std.measure`: this module defines its own `measure` below, and
              // a plain name here would be a trap for anyone moving this code.
              box(width: std.measure(footnote-style(fake)).width)
            }
          })
        }
      } else if type(child) == content and child.func() in (cite, ref) {
        // A note-style citation only becomes a footnote during layout, after
        // the scan above, so `hide()` drops the marker while its queued entry
        // still reaches the page. Same three branches as `footnote`.
        if repetitions <= index or not need-cover {
          result.push(child)
        } else if not utils.cover-hides-footnote(self) {
          hidden-parts.push(child)
        } else {
          hidden-parts.push({
            show cite: none
            show ref: none
            child
          })
        }
      } else if (
        type(child) == content
          and (
            tree.shape-of(child) == "math"
              or child.func() in (math.vec, math.cases)
          )
      ) {
        // Math elements keep their sub-content in named fields of their own,
        // so `tree.children-of`/`tree.rebuild` do the taking apart and putting
        // back. Without this a `#pause` inside `frac(..)` or `mat(..)` is
        // never reached and reports itself as an unsupported mark.
        //
        // `vec`/`cases` hold theirs in `children`, which `tree` also handles;
        // they come here rather than through the single-body allowlist below.
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
          inner-has-fn-wrapper,
          inner-min-repetitions,
        ) = parse-and-reconstruct(
          self,
          child,
          "tree",
          repetitions,
          last-subslide,
          index,
          need-cover,
          (c, new) => tree.rebuild(c, new),
        )
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
      } else if (
        type(child) == content and child.func() in reconstructable-functions
      ) {
        // A figure holds a caption as well as a body, so it is walked in
        // "tree" mode: `tree.children-of` hands back `(body, caption)` and the
        // two are parsed one after the other, the caption continuing from
        // where the body left off. `tree.rebuild` puts the figure back.
        let is-figure = child.func() == figure
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
          inner-has-fn-wrapper,
          inner-min-repetitions,
        ) = parse-and-reconstruct(
          self,
          child,
          if is-figure { "tree" } else { "body-or-none" },
          repetitions,
          last-subslide,
          index,
          need-cover,
          (child, cont) => if is-figure {
            tree.rebuild(labeled: labeled(child.func()), child, cont)
          } else {
            tree.reconstruct(
              named: true,
              labeled: labeled(child.func()),
              child,
              cont,
            )
          },
        )
        // Cover a figure's caption when none of it is on this subslide. The
        // caption sits after the body, so it is parsed from where the body
        // ended; `calc.min` of that start against where the caption ends is
        // the same test the other branches use to honour a `#meanwhile`, which
        // rewinds the counter and can be wound forward again by a later
        // `#pause`.
        if is-figure and child.caption != none and need-cover {
          let (_, _, _, after-body, ..) = (
            _parse-content-into-results-and-repetitions(
              self: self,
              need-cover: false,
              base: repetitions,
              base-last-subslide: last-subslide,
              index: index,
              child.body,
            )
          )
          // `caption-min` is the lowest the counter reaches inside the
          // caption, so a `#meanwhile` that rewinds it to run alongside the
          // body is honoured even when a later `#pause` winds it forward
          // again -- which the end value alone cannot show.
          let (_, _, _, _, _, caption-min) = (
            _parse-content-into-results-and-repetitions(
              self: self,
              need-cover: false,
              base: after-body,
              base-last-subslide: last-subslide,
              index: index,
              child.caption,
            )
          )
          if repetitions <= index and caption-min > index {
            // The walk covered the caption's content as it went, and covering
            // it a second time through the show rule breaks it away from its
            // supplement onto a line of its own. Re-parse it with covering
            // off -- the marks are still resolved, so nothing escapes -- and
            // let `cover-caption` cover it once, supplement included.
            let (uncovered-caption, ..) = (
              _parse-content-into-results-and-repetitions(
                self: self,
                need-cover: false,
                base: after-body,
                base-last-subslide: last-subslide,
                index: index,
                child.caption,
              )
            )
            reconstructed = cover-caption(
              tree.rebuild(
                labeled: labeled(child.func()),
                reconstructed,
                (reconstructed.body, uncovered-caption.first()),
              ),
            )
          }
        }
        // Propagate meanwhile effect from inside the reconstructable element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
      } else if type(child) == content and child.func() == terms.item {
        // handle the terms item
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
          inner-has-fn-wrapper,
          inner-min-repetitions,
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
            {
              let covered = cover-hidden(cover, hidden-parts, result)
              result = covered.result
              result.push(covered.covered)
            }
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
        min-repetitions = calc.min(min-repetitions, repetitions)
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        min-repetitions = calc.min(min-repetitions, inner-min-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
      } else {
        if repetitions <= index or not need-cover {
          result.push(child)
        } else {
          hidden-parts.push(child)
        }
      }
    }
    // The last waypoint's run ends with the body, so its anchor goes here.
    if open-waypoint != none {
      result.push(waypoint-anchor(
        slide-label,
        open-waypoint,
        wp-map: self.at("waypoints", default: (:)),
        index: index,
        rendered: self.at("rendered-subslides", default: none),
      ))
      open-waypoint = none
    }
    // clear the hidden-parts when end
    if hidden-parts.len() != 0 {
      {
        let covered = cover-hidden(cover, hidden-parts, result)
        result = covered.result
        result.push(covered.covered)
      }
      hidden-parts = ()
    }
    parsed-results.push(result.sum(default: []))
  }
  max-repetitions = calc.max(max-repetitions, repetitions)
  min-repetitions = calc.min(min-repetitions, repetitions)
  return (
    parsed-results,
    max-repetitions,
    last-subslide,
    repetitions,
    has-fn-wrapper,
    min-repetitions,
  )
}


/// Prepare the rendering context for a touying-render node.
/// Computes waypoints, max repetitions, and reducer metadata from inline content.
///
/// Returns: `(reducer-data, cwp, repeat, max-rep-raw)`
/// - `reducer-data`: reducer metadata dict if content is a reducer, else `none`
/// - `cwp`: computed waypoint ranges, numbered from `render-base`, so they
///   need no shifting to line up with `repeat`
/// - `repeat`: max repetitions (including waypoints)
/// - `max-rep-raw`: raw max repetitions from the content's animation (before waypoints)
#let _prepare-render-context(self, inline-content, render-base) = {
  // Only a value that is *entirely* one reducer takes the reducer path. A
  // reducer nested in other content goes through the ordinary parser, which
  // keeps the siblings and wrappers around it.
  let reducer-data = if tree.is-kind(inline-content, "touying-reducer") {
    inline-content.value
  }
  let (raw-wp, so, dr) = _collect-waypoints(
    base: render-base,
    inline-content,
  )
  let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
  // A waypoint reference has to be resolvable during the first measurement,
  // while its range still needs a repeat bound. Start from the positions the
  // static walk already knows, measure against that provisional map, then
  // close the ranges again over the measured extent.
  let provisional-cwp = _compute-waypoint-ranges(
    resolved-wp,
    calc.max(render-base, ..resolved-wp.values(), 1),
    so,
    dr,
  )
  let max-rep-raw = if reducer-data != none {
    let (_, mrr, ..) = _parse-touying-reducer(
      self: self + (waypoints: provisional-cwp, subslide: 9999),
      base: render-base,
      index: 9999,
      reducer-data,
    )
    mrr
  } else {
    let (_, mrr, ls, ..) = _parse-content-into-results-and-repetitions(
      self: self + (waypoints: provisional-cwp, subslide: 9999),
      base: render-base,
      index: 9999,
      inline-content,
    )
    calc.max(mrr, ls)
  }
  let repeat = calc.max(
    max-rep-raw,
    render-base,
    ..resolved-wp.values(),
    1,
  )
  let cwp = _compute-waypoint-ranges(resolved-wp, repeat, so, dr)
  (reducer-data, cwp, repeat, max-rep-raw)
}


/// Render inline content at a specific target subslide.
///
/// `show-delayed-wrapper` emits the body of a delayed wrapper instead of
/// dropping it. Article mode renders a run once, so a wrapper whose content
/// would otherwise wait for a later subslide has to contribute here.
///
/// Returns: rendered content (or `none`)
#let _render-at-subslide(
  self,
  inline-content,
  reducer-data,
  cwp,
  render-base,
  target,
  show-delayed-wrapper: false,
) = {
  let render-self = self + (waypoints: cwp, subslide: target)
  if reducer-data != none {
    let (r, ..) = _parse-touying-reducer(
      self: render-self,
      base: render-base,
      index: target,
      reducer-data,
    )
    r.sum(default: none)
  } else {
    let (conts, ..) = _parse-content-into-results-and-repetitions(
      self: render-self,
      base: render-base,
      index: target,
      show-delayed-wrapper: show-delayed-wrapper,
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
        // The map was collected from `render-base`, so it already uses the
        // same absolute numbering as `repeat` above.
        _resolve-waypoint-to-int((waypoints: cwp), subslides)
      } else {
        // `repeat` is the absolute final index, so convert it to a plain
        // stage count before resolving negative indices against `base`.
        resolve-negative-subslides(
          repeat - render-base + 1,
          subslides,
          base: render-base,
        )
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



/// Measure content that may contain touying animations.
///
/// Typst's own `measure` sees touying's animation functions as bare metadata
/// marks, which occupy no space: `std.measure(#uncover("2-")[U])` returns a height
/// of `0pt`, while the same content written with `#pause` measures correctly.
/// This parses the body the way a slide would, renders it at one subslide, and
/// measures *that*, so the result matches what the slide will actually show.
///
/// It is a drop-in replacement of the normal `measure` function.
/// Like `measure`, this must be called from a context — and it deliberately
/// opens none of its own, so it returns a *dictionary* the caller can compute
/// with rather than opaque content. It also inherits the caller's region, so
/// it behaves correctly inside `layout`:
///
/// ```typst
/// #import "@preview/touying:0.8.0": measure
/// #context {
///   let body = [...] //some animated content
///   let h = measure(body, width: 100%).height
///   // ... use h in arithmetic ...
/// }
/// ```
///
/// - body (content): The content to measure.
///
/// - subslide (auto, none, int, label, dictionary): Which subslide to measure.
///   - `auto` (default): the last subslide, i.e. the fully revealed state.
///     Content with no animations has exactly one, so this is the whole of it.
///   - `none`: the largest width and height over *every* subslide. Each
///     dimension is maximised independently.
///   - `int`: that subslide, counted in `body`'s own numbering (see `base`).
///   - a waypoint label or marker: resolved against `body`'s own waypoints.
///
/// - base (auto, int): Starting value of `body`'s internal subslide counter,
///   exactly as in `touying-render`. `auto` (default) means `1`, so a
///   `subslide` number here means the same thing it would there.
///
/// - args (any): Everything else is forwarded to `measure` unchanged, so
///   `width` and `height` work as usual.
///
/// -> dictionary
#let measure(body, subslide: auto, base: auto, ..args) = {
  // The cover method only has to reserve space, never to look right: nothing
  // measured here is shown. `hide` keeps the covered content's own size, which
  // is exactly what a measurement needs.
  let minimal-self = (
    methods: (cover: utils.method-wrapper(hide)),
    waypoints: (:),
    subslide: 1,
  )
  let render-base = if base == auto { 1 } else { base }
  let (reducer-data, cwp, repeat, _) = _prepare-render-context(
    minimal-self,
    body,
    render-base,
  )
  let render-at(target) = _render-at-subslide(
    minimal-self,
    body,
    reducer-data,
    cwp,
    render-base,
    target,
  )
  if subslide == none {
    // Maximise each dimension independently over every subslide: the widest
    // and the tallest subslide need not be the same one.
    // `std.measure`: this module now binds `measure` to this very function,
    // so a bare call would recurse.
    let sizes = range(render-base, repeat + 1).map(
      target => std.measure(render-at(target), ..args),
    )
    (
      width: calc.max(..sizes.map(s => s.width)),
      height: calc.max(..sizes.map(s => s.height)),
    )
  } else {
    let target = if subslide == auto {
      repeat
    } else if (
      type(subslide) == label
        or (
          type(subslide) == dictionary
            and subslide.at("kind", default: "") in waypoint-kinds
        )
    ) {
      // `cwp` was collected from `render-base`, so the resolved position is
      // already in the same numbering as `repeat` above.
      _resolve-waypoint-to-int((waypoints: cwp), subslide)
    } else {
      // `repeat` is the absolute final index, so convert it to a plain stage
      // count before resolving negative indices against `base`.
      resolve-negative-subslides(
        repeat - render-base + 1,
        subslide,
        base: render-base,
      )
    }
    std.measure(render-at(target), ..args)
  }
}
