#import "../common.typ": *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none, export-mode: "article"),
)

#body
#reuse-body

== Check <s:check>

#context {
  assert-common()

  // Article mode has no subslides at all: the body is rendered once, so the
  // anchors are placed by position in the content rather than by subslide.
  // Both land in the flowing text of the first slide.
  assert.eq(page-of("s:one.more"), 1)
  assert.eq(page-of("s:one.last"), 1)
}
