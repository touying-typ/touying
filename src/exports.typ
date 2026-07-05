//metadata emitters
#import "core/animation.typ": (
  alternatives, alternatives-cases, alternatives-fn, alternatives-match, effect,
  handout-only, item-by-item, item-by-item-fn, item-by-item-functions, jump,
  meanwhile, only, pause, presentation-only, slides-only, touying-fn-wrapper,
  touying-render, touying-slide-wrapper, uncover,
)
#import "core/blocks.typ": (
  alert, lr-navigation, speaker-note, touying-diagram, touying-equation,
  touying-fn-wrapper-raw, touying-mitex, touying-raw, touying-reduce,
  touying-reducer,
)
#import "core/waypoints.typ": (
  from-wp, get-first, get-last, next-wp, not-wp, prev-wp, until-wp, waypoint,
)
// rendering logic: for document-mode and slides-mode: rely on parser.typ for parsing the metadata
#import "core/docmode.typ": document-only, document-text, touying-block-recall
#import "core/slides.typ": (
  appendix, empty-slide, slide, touying-recall, touying-set-config,
  touying-slide,
)
//configs
#import "configs.typ": (
  config-colors, config-common, config-document, config-info, config-methods,
  config-page, config-store, default-config, touying-get-config,
)
//entrypoint
#import "entrypoint.typ": touying-slides
//other
#import "utils.typ"
#import "magic.typ"
#import "pdfpc.typ"
#import "components.typ": cols, lazy-h, lazy-layout, lazy-v, side-by-side
#import "components.typ"

#import "extern.typ": touying-disable-warnings, touying-enable-warnings
