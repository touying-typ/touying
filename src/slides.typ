#import "utils.typ"
#import "configs.typ"
#import "core.typ"

#let touying-slides(..args, body) = {
  assert(args.named().len() == 0, message: "unexpected named arguments:" + repr(args.named().keys()))
  let args = (configs.default-config,) + args.pos()
  let self = utils.merge-dicts(..args)

  show: core.split-content-into-slides.with(self: self, is-first-slide: true)

  body
}
