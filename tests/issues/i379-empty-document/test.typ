// This is intentionally a compile-only tytanic test without `ref/*.png`.
// The regression is an empty-document compilation crash, so a successful
// compile is the assertion and no visual output is expected.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [A title],
  ),
)
