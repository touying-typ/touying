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
#context {
  let h = query(heading)
  v(2em)
  for hd in h {
    text(size: 1em, fill: red)[#hd.body = page #hd.location().page() | ]
  }
  linebreak()
  text(fill: blue, size: 1.2em)[Current page: #here().page()]
}
inner1

= Subtitle 2
== subsub2
inner2
