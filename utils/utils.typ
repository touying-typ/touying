// OOP: call it or display it
#let call-or-display(self, it) = {
  if type(it) == function {
    return it(self)
  } else {
    return it
  }
}

// OOP: empty page
#let empty-page(self) = {
  self.page-args += (
    header: none,
    footer: none,
    margin: 0em,
  )
  self.padding = (x: 0em, y: 0em)
  self
}

// OOP: wrap methods
#let wrap-method(fn) = (self: none, ..args) => fn(..args)

// OOP: assuming all functions in dictionary have a named `self` parameter,
// `methods` function is used to get all methods in dictionary object
#let methods(self) = {
  assert(type(self) == dictionary, message: "self must be a dictionary")
  assert("methods" in self and type(self.methods) == dictionary, message: "self.methods must be a dictionary")
  let methods = (:)
  for key in self.methods.keys() {
    if type(self.methods.at(key)) == function {
      methods.insert(key, (..args) => self.methods.at(key)(self: self, ..args))
    }
  }
  return methods
}

// touying wrapper mark
#let touying-wrapper(name, fn, ..args) = {
  metadata((
    kind: "touying-wrapper",
    name: name,
    fn: fn,
    args: args,
  ))
}

#let slides(self) = {
  let m = methods(self)
  let res = (:)
  for key in m.keys() {
    res.insert(key, touying-wrapper.with(key, m.at(key)))
  }
  return res
}

// Utils: unify section
#let unify-section(section) = {
  if section == none {
    return none
  } else if type(section) == dictionary {
    return section + (short-title: section.at("short-title", default: auto))
  } else if type(section) == array {
    return (title: section.at(0), short-title: section.at(1, default: auto))
  } else {
    return (title: section, short-title: auto)
  }
}

#let section-short-title(section) = {
  if type(section) == dictionary {
    if section.short-title == auto {
      return section.title
    } else {
      return section.short-title
    }
  } else {
    return section
  }
}

// Utils: trim
#let trim(arr) = {
  let i = 0
  while arr.len() != i and arr.at(i) in ([], [ ], parbreak(), linebreak()) {
    i += 1
  }
  arr.slice(i)
}

// Type: is sequence
#let is-sequence(it) = {
  type(it) == content and it.has("children")
}

#let reconstruct(body-name: "body", named: false, it, body) = {
  let fields = it.fields()
  let _ = fields.remove("label", default: none)
  let _ = fields.remove(body-name, default: none)
  if named {
    return (it.func())(..fields, body)
  } else {
    return (it.func())(..fields.values(), body)
  }
}

#let heading-depth(it) = {
  if it.has("depth") {
    it.depth
  } else {
    it.level
  }
}

// Code: HEIGHT/WIDTH FITTING and cover-with-rect
// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/pull/91
// Author: ntjess

#let _size-to-pt(size, styles, container-dimension) = {
  let to-convert = size
  if type(size) == "ratio" {
    to-convert = container-dimension * size
  }
  measure(v(to-convert), styles).height
}

#let _limit-content-width(width: none, body, container-size, styles) = {
  let mutable-width = width
  if width == none {
    mutable-width = calc.min(container-size.width, measure(body, styles).width)
  } else {
    mutable-width = _size-to-pt(width, styles, container-size.width)
  }
  box(width: mutable-width, body)
}

#let fit-to-height(
  width: none, prescale-width: none, grow: true, shrink: true, height, body
) = {
  // Place two labels with the requested vertical separation to be able to
  // measure their vertical distance in pt.
  // Using this approach instead of using `measure` allows us to accept fractions
  // like `1fr` as well.
  // The label must be attached to content, so we use a show rule that doesn't
  // display anything as the anchor.
  let before-label = label("touying-fit-height-before")
  let after-label = label("touying-fit-height-after")
  [
    #show before-label: none
    #show after-label: none
    #v(1em)
    hidden#before-label
    #v(height)
    hidden#after-label
  ]

  locate(loc => {
    let before = query(selector(before-label).before(loc), loc)
    let before-pos = before.last().location().position()
    let after = query(selector(after-label).before(loc), loc)
    let after-pos = after.last().location().position()

    let available-height = after-pos.y - before-pos.y

    style(styles => {
      layout(container-size => {
        // Helper function to more easily grab absolute units
        let get-pts(body, w-or-h) = {
          let dim = if w-or-h == "w" {container-size.width} else {container-size.height}
          _size-to-pt(body, styles, dim)
        }

        // Provide a sensible initial width, which will define initial scale parameters.
        // Note this is different from the post-scale width, which is a limiting factor
        // on the allowable scaling ratio
        let boxed-content = _limit-content-width(
          width: prescale-width, body, container-size, styles
        )

        // post-scaling width
        let mutable-width = width
        if width == none {
          mutable-width = container-size.width
        }
        mutable-width = get-pts(mutable-width, "w")

        let size = measure(boxed-content, styles)
        if size.height == 0pt or size.width == 0pt {
          return body
        }
        let h-ratio = available-height / size.height
        let w-ratio = mutable-width / size.width
        let ratio = calc.min(h-ratio, w-ratio) * 100%

        if (
          (shrink and (ratio < 100%))
          or (grow and (ratio > 100%))
        ) {
          let new-width = size.width * ratio
          v(-available-height)
          // If not boxed, the content can overflow to the next page even though it will
          // fit. This is because scale doesn't update the layout information.
          // Boxing in a container without clipping will inform typst that content
          // will indeed fit in the remaining space
          box(
            width: new-width,
            height: available-height,
            scale(x: ratio, y: ratio, origin: top + left, boxed-content)
          )
        } else {
          body
        }
      })
    })
  })
}

#let fit-to-width(grow: true, shrink: true, width, content) = {
  style(styles => {
    layout(layout-size => {
      let content-size = measure(content, styles)
      let content-width = content-size.width
      let width = _size-to-pt(width, styles, layout-size.width)
      if (
        content-width != 0pt and
        ((shrink and (width < content-width))
        or (grow and (width > content-width)))
      ) {
        let ratio = width / content-width * 100%
        // The first box keeps content from prematurely wrapping
        let scaled = scale(
          box(content, width: content-width), origin: top + left, x: ratio, y: ratio
        )
        // The second box lets typst know the post-scaled dimensions, since `scale`
        // doesn't update layout information
        box(scaled, width: width, height: content-size.height * ratio)
      } else {
        content
      }
    })
  })
}

// semitransparency cover
#let cover-with-rect(..cover-args, fill: auto, inline: true, body) = {
  if fill == auto {
    panic(
      "`auto` fill value is not supported until typst provides utilities to"
      + " retrieve the current page background"
    )
  }
  if type(fill) == "string" {
    fill = rgb(fill)
  }

  let to-display = layout(layout-size => {
    style(styles => {
      let body-size = measure(body, styles)
      let bounding-width = calc.min(body-size.width, layout-size.width)
      let wrapped-body-size = measure(box(body, width: bounding-width), styles)
      let named = cover-args.named()
      if "width" not in named {
        named.insert("width", wrapped-body-size.width)
      }
      if "height" not in named {
        named.insert("height", wrapped-body-size.height)
      }
      if "outset" not in named {
        // This outset covers the tops of tall letters and the bottoms of letters with
        // descenders. Alternatively, we could use
        // `set text(top-edge: "bounds", bottom-edge: "bounds")` to get the same effect,
        // but this changes text alignment and also misaligns bullets in enums/lists.
        // In contrast, `outset` preserves spacing and alignment at the cost of adding
        // a slight, visible border when the covered object is right next to the edge
        // of a color change.
        named.insert("outset", (top: 0.15em, bottom: 0.25em))
      }
      stack(
        spacing: -wrapped-body-size.height,
        body,
        rect(fill: fill, ..named, ..cover-args.pos())
      )
    })
  })
  if inline {
    box(to-display)
  } else {
    to-display
  }
}

#let update-alpha(constructor: rgb, color, alpha) = constructor(..color.components(alpha: true).slice(0, -1), alpha)


// Code: check visible subslides and dynamic control
// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/blob/main/logic.typ
// Author: Andreas Kröpelin

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
      ( until: parsed )
    } else if match-beginning != none {
      let parsed = int(match-beginning.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      ( beginning: parsed )
    } else if match-range != none {
      let parsed-first = int(match-range.captures.first())
      let parsed-last = int(match-range.captures.last())
      // assert(parsed-first > 0, "parsed idx is non-positive")
      // assert(parsed-last > 0, "parsed idx is non-positive")
      ( beginning: parsed-first, until: parsed-last )
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

#let check-visible(idx, visible-subslides) = {
  if type(visible-subslides) == "integer" {
    idx == visible-subslides
  } else if type(visible-subslides) == "array" {
    visible-subslides.any(s => check-visible(idx, s))
  } else if type(visible-subslides) == "string" {
    let parts = _parse-subslide-indices(visible-subslides)
    check-visible(idx, parts)
  } else if type(visible-subslides) == content and visible-subslides.has("text") {
    let parts = _parse-subslide-indices(visible-subslides.text)
    check-visible(idx, parts)
  } else if type(visible-subslides) == "dictionary" {
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
  } else {
    panic("you may only provide a single integer, an array of integers, or a string")
  }
}

#let uncover(self: none, visible-subslides, uncover-cont) = {
  let cover = self.methods.cover.with(self: self)
  if check-visible(self.subslide, visible-subslides) { 
    uncover-cont
  } else {
    cover(uncover-cont)
  }
}

#let only(self: none, visible-subslides, only-cont) = {
  if check-visible(self.subslide, visible-subslides) { only-cont }
}

#let alternatives-match(self: none, subslides-contents, position: bottom + left) = {
  let subslides-contents = if type(subslides-contents) == "dictionary" {
    subslides-contents.pairs()
  } else {
    subslides-contents
  }

  let subslides = subslides-contents.map(it => it.first())
  let contents = subslides-contents.map(it => it.last())
  style(styles => {
    let sizes = contents.map(c => measure(c, styles))
    let max-width = calc.max(..sizes.map(sz => sz.width))
    let max-height = calc.max(..sizes.map(sz => sz.height))
    for (subslides, content) in subslides-contents {
      only(self: self, subslides, box(
        width: max-width,
        height: max-height,
        align(position, content)
      ))
    }
  })
}

#let alternatives(
  self: none,
  start: 1,
  repeat-last: true,
  ..args
) = {
  let contents = args.pos()
  let kwargs = args.named()
  let subslides = range(start, start + contents.len())
  if repeat-last {
    subslides.last() = (beginning: subslides.last())
  }
  alternatives-match(self: self, subslides.zip(contents), ..kwargs)
}

#let alternatives-fn(
  self: none,
  start: 1,
  end: none,
  count: none,
  ..kwargs,
  fn
) = {
  let end = if end == none {
    if count == none {
      panic("You must specify either end or count.")
    } else {
      start + count
    }
  } else {
    end
  }

  let subslides = range(start, end)
  let contents = subslides.map(fn)
  alternatives-match(self: self, subslides.zip(contents), ..kwargs.named())
}

#let alternatives-cases(self: none, cases, fn, ..kwargs) = {
  let idcs = range(cases.len())
  let contents = idcs.map(fn)
  alternatives-match(self: self, cases.zip(contents), ..kwargs.named())
}

// SIDE BY SIDE

#let side-by-side(columns: auto, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto { (1fr,) * bodies.len() } else { columns }
  grid(columns: columns, gutter: gutter, ..bodies)
}