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
            []
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