#import "../src/exports.typ": *

#let slide(
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


#let default-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
    ),
    ..args,
  )

  body
}