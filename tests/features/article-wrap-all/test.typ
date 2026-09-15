// The boolean shorthand `wrap: true` floats every extractable candidate.
// Keep this paired with the `wrap: false` regression: normalizing one boolean
// must not accidentally capture the subsequently reassigned config value.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(wrap: true),
)

== All candidates

#image("/tests/features/article-mode/image.png")

#table(
  columns: 2,
  [A], [B],
)

#lorem(80)
