#import "utils/utils.typ": empty-object, methods, is-sequence

// touying pause mark
#let pause = [#"<touying-pause>"]

// parse a sequence into content, and get the repetitions
#let _parse-content-with-pause(self: empty-object, base: 1, index: 1, it) = {
  // get cover function from self
  let cover = self.cover
  // if it is a function, then call it with self, uncover and only
  if type(it) == function {
    // register the methods
    self.methods.uncover = (self: empty-object, i, uncover-cont) => if i == index { uncover-cont } else { cover(uncover-cont) }
    self.methods.only = (self: empty-object, i, only-cont) => if i == index { only-cont }
    it = it(self)
  }
  // repetitions
  let repetitions = base
  // parse the content
  let uncover-arr = ()
  let cover-arr = ()
  if is-sequence(it) {
    for child in it.children {
      if child == pause {
        repetitions += 1
      } else {
        if repetitions <= index {
          uncover-arr.push(child)
        } else {
          cover-arr.push(child)
        }
      }
    }
  } else {
    uncover-arr.push(it)
  }
  return (uncover-arr.sum(default: []) + if cover-arr.len() > 0 { cover(cover-arr.sum()) }, repetitions)
}

// touying-slide
#let touying-slide(self: empty-object, repeat: auto, body) = {
  // for multiple pages
  if repeat == none {
    return {
      set page(..self.page-args)
      body
    }
  }
  // for single page slide, get the repetitions
  if repeat == auto {
    let (_, repetitions) = _parse-content-with-pause(
      self: self,
      base: 1,
      index: 1,
      body,
    )
    repeat = repetitions
  }
  // render all the subslides
  let result = ()
  let current = 1
  for i in range(1, repeat + 1) {
    let (cont, _) = _parse-content-with-pause(self: self, index: i, body)
    result.push(page(..self.page-args, cont))
  }
  // return the result
  return result.sum()
}

// build the touying singleton
#let s = {
  let self = empty-object + (
    cover: hide,
    handout: false,
    page-args: (
      paper: "presentation-16-9",
      header: none,
      footer: none,
    )
  )
  // register the methods
  self.methods.touying-slide = touying-slide
  self.methods.init = (self: empty-object, body) => {
    set text(size: 20pt)
    body
  }
  self
}