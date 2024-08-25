#import "utils.typ"
#import "configs.typ": *


/// Wrapper for a slide function
///
/// - `fn` (self => { .. }): The function that will be called to render the slide
#let touying-slide-wrapper(fn) = utils.label-it(
  metadata((
    kind: "touying-slide-wrapper",
    fn: fn,
  )),
  "touying-temporary-mark",
)


/// Recall a slide by its label
///
/// - `lbl` (str): The label of the slide to recall
#let touying-recall(lbl) = utils.label-it(
  metadata((
    kind: "touying-slide-recaller",
    label: if type(lbl) == label {
      str(lbl)
    } else {
      lbl
    },
  )),
  "touying-temporary-mark",
)


/// Call touying slide function
#let call-slide-fn(self, fn, body) = {
  let slide-wrapper = fn(body)
  assert(
    utils.is-kind(slide-wrapper, "touying-slide-wrapper"),
    message: "you must use `touying-slide-wrapper` in your slide function",
  )
  return (slide-wrapper.value.fn)(self)
}


/// Use headings to split a content block into slides
#let split-content-into-slides(self: none, recaller-map: (:), body) = {
  // Extract arguments
  assert(type(self) == dictionary, message: "`self` must be a dictionary")
  assert("slide-level" in self and type(self.slide-level) == int, message: "`self.slide-level` must be an integer")
  assert("slide-fn" in self and type(self.slide-fn) == function, message: "`self.slide-fn` must be a function")
  let slide-level = self.slide-level
  let slide-fn = self.slide-fn
  let horizontal-line-to-pagebreak = self.at("horizontal-line-to-pagebreak", default: true)
  let children = if utils.is-sequence(body) {
    body.children
  } else {
    (body,)
  }
  let get-last-heading-depth(current-headings) = {
    if current-headings != () {
      current-headings.at(-1).depth
    } else {
      0
    }
  }
  let get-last-heading-label(current-headings) = {
    if current-headings != () {
      if current-headings.at(-1).has("label") {
        str(current-headings.at(-1).label)
      }
    }
  }
  let call-slide-fn-and-reset(self, slide-fn, current-slide-cont, recaller-map) = {
    let cont = call-slide-fn(self, slide-fn, current-slide-cont)
    let last-heading-label = get-last-heading-label(self.headings)
    if last-heading-label != none {
      recaller-map.insert(last-heading-label, cont)
    }
    (cont, recaller-map, (), (), true)
  }
  // The empty content list
  let empty-contents = ([], [ ], parbreak(), linebreak())
  // The headings that we currently have
  let current-headings = ()
  // Recaller map
  let recaller-map = recaller-map
  // The current slide we are building
  let current-slide = ()
  // The current slide content
  let cont = none
  // Is the first part should be a slide
  let first-slide = false


  // Is we have a horizontal line
  let horizontal-line = false
  // Iterate over the children
  for child in children {
    // Handle horizontal-line
    // split content when we have a horizontal line
    if horizontal-line-to-pagebreak and horizontal-line and child not in ([—], [–], [-]) {
      current-slide = utils.trim(current-slide)
      (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings),
        slide-fn,
        current-slide.sum(default: none),
        recaller-map,
      )
      cont
    }
    // Main logic
    if utils.is-kind(child, "touying-slide-wrapper") {
      current-slide = utils.trim(current-slide)
      if current-slide != () {
        (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        cont
      }
      (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings),
        child.value.fn,
        current-slide.sum(default: none),
        recaller-map,
      )
      cont
    } else if utils.is-kind(child, "touying-slide-recaller") {
      current-slide = utils.trim(current-slide)
      if current-slide != () or current-headings != () {
        (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        cont
      }
      let lbl = child.value.label
      assert(lbl in recaller-map, message: "label not found in the recaller map for slides")
      // recall the slide
      recaller-map.at(lbl)
    } else if child == pagebreak() {
      // split content when we have a pagebreak
      current-slide = utils.trim(current-slide)
      (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings),
        slide-fn,
        current-slide.sum(default: none),
        recaller-map,
      )
      cont
    } else if horizontal-line-to-pagebreak and child == [—] {
      horizontal-line = true
      continue
    } else if horizontal-line-to-pagebreak and horizontal-line and child in ([–], [-]) {
      continue
    } else if utils.is-heading(child, depth: slide-level) {
      let last-heading-depth = get-last-heading-depth(current-headings)
      if child.depth <= last-heading-depth {
        current-slide = utils.trim(current-slide)
        (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        cont
      }
      current-headings.push(child)
      first-slide = true
    } else {
      let child = if utils.is-sequence(child) {
        // Split the content into slides recursively
        split-content-into-slides(self: self, recaller-map: recaller-map, child)
      } else if utils.is-styled(child) {
        // Split the content into slides recursively for styled content
        utils.reconstruct-styled(child, split-content-into-slides(self: self, recaller-map: recaller-map, child.child))
      } else {
        child
      }
      if first-slide {
        // Add the child to the current slide
        current-slide.push(child)
      } else {
        child
      }
    }
  }

  // Handle the last slide
  current-slide = utils.trim(current-slide)
  if current-slide != () or current-headings != () {
    (cont, recaller-map, current-headings, current-slide, first-slide) = call-slide-fn-and-reset(
      self + (headings: current-headings),
      slide-fn,
      current-slide.sum(default: none),
      recaller-map,
    )
    cont
  }
}

#show: split-content-into-slides.with(self: default-config + config-common(slide-fn: body => touying-slide-wrapper(self => [
  #set page(paper: "presentation-16-9")

  #self.headings

  #body
])))

= sdfsdf

== recall

sdf

== recall

sdf

= sdfsdfsdf

sdfddd
