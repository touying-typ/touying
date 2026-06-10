#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [A title],
  ),
)

#slide(repeat: 3, self => {
  // use callback style
  let (uncover, only, alternatives) = utils.methods(self)

  // applying uncover via a show rule is broken
  show list.item: it => uncover("2-", it)
  [
    - hi
    // callback-style uncover works here
    - #uncover("2-")[hello]
    
    // using callback-style uncover in context is also broken, despite being an explicit use case for callback-style
    - #context uncover("3-", text.lang)
  ]
})