// Minimal reproduction - testing what exactly causes the page anchor issue
#import "/lib.typ": *
#import themes.simple: *

// Test 1: Section slide with ONLY context blocks (buggy)
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(
    new-section-slide-fn: section => touying-slide-wrapper(self => {
      touying-slide(
        self: self,
        // Body: only context blocks (no layout-triggering content)
        context utils.display-current-heading(level: 1)
      )
    }),
  ),
)

= Section 1
== Sub 1
#context {
  let h = query(heading)
  text(fill: red)[Sub1 page: #h.find(h => h.body == [Sub 1]).location().page() | Sub2 page: #h.find(h => h.body == [Sub 2]).location().page()]
}
Content 1

= Section 2
== Sub 2
Content 2
