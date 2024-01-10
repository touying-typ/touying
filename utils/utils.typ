// OOP: empty object
#let empty-object = (methods: (:))

// OOP: call it or display it
#let call-or-display(self, it) = {
  if type(it) == function {
    return it(self)
  } else {
    return it
  }
}

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


// Type: is sequence
#let is-sequence(it) = {
  type(it) == content and it.has("children")
}


// HEIGHT/WIDTH FITTING, code from [@ntjess](https://github.com/ntjess)

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