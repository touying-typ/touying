// Float widths accept ratios, relative lengths, and absolute lengths. The
// latter two must be resolved differently from a ratio instead of being
// multiplied by the parent width.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(wrap: (
    image: 3cm,
    figure: (width: 40% + 5mm),
  )),
)

== Widths

#image("/tests/features/article-mode/image.png")

#figure(
  image("/tests/features/article-mode/image.png"),
  caption: [Relative float width],
)

#lorem(80)
