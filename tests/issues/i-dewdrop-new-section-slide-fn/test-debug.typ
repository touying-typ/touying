// Debug version to check page numbers of headings
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
            // Debug: show current page and all heading pages
            context {
              let headings = query(heading)
              let pg = here().page()
              text(size: 0.5em)[Page: #pg | Headings: #headings.map(h => h.body + ":" + str(h.location().page())).join(", ")]
            }
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
  let headings = query(heading)
  let pg = here().page()
  text(size: 0.5em)[Page: #pg | Headings: #headings.map(h => h.body + ":" + str(h.location().page())).join(", ")]
}
inner1

= Subtitle 2
== subsub2
inner2
