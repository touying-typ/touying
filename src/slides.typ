#import "utils.typ"
#import "configs.typ"
#import "core.typ"

/// Touying slides function.
///
/// #example(```
/// #show: touying-slides.with(
///   config-page(paper: "presentation-" + aspect-ratio),
///   config-common(
///     slide-fn: slide,
///   ),
///   ..args,
/// )
/// ```)
///
/// `..args` is the configurations of the slides. For example, you can use `config-page(paper: "presentation-16-9")` to set the aspect ratio of the slides.
///
/// `body` is the contents of the slides.
#let touying-slides(..args, body) = {
  assert(args.named().len() == 0, message: "unexpected named arguments:" + repr(args.named().keys()))
  let args = (configs.default-config,) + args.pos()
  let self = utils.merge-dicts(..args)

  show: core.split-content-into-slides.with(self: self, is-first-slide: true)

  body
}
