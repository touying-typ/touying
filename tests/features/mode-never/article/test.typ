// See ../presentation/test.typ for what `<touying:never>` guarantees.
//
// Article mode is asserted differently from the two slide modes. A `#context`
// block here is not a reliable probe: with the feature disabled the queries
// below return the wrong counts (verified with an explicit panic) and yet the
// assertions do not fire, so a context-based test passes vacuously. Comparing
// the rendered text is sensitive, so that is what this does.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(export-mode: "article"),
)

= Kept
KEEPMARK

= Dropped <touying:never>
DROPMARK
#speaker-note[This note must vanish with its section.]

= Typo <touying:never-presentation>
TYPOMARK
