// Issue: Strange behaviour of dewdrop theme with new-section-slide-fn
// https://github.com/touying-typ/touying/issues/388
// When a custom new-section-slide-fn body contains only context elements
// (lazily evaluated), Typst fails to properly anchor the page layout in the
// first pass. This caused hidden headings from subsequent slides to receive
// incorrect page assignments, making context queries return wrong headings.

#import "/lib.typ": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  config-common(
    new-section-slide-fn: (section => {
      touying-slide-wrapper(self => {
        touying-slide(
          self: self,
          {
            utils.display-current-heading(level: 1)
            components.mini-slides(fill: self.colors.primary, display-subsection: false)
          },
        )
      }
    )
    }),
  ),
  navigation: none,
)

= Subtitle 1
== subsub1
inner1

= Subtitle 2
== subsub2
inner2
