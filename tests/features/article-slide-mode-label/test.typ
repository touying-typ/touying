// Explicit slide calls carry their user label on the wrapper block. Article
// mode must move that label onto the inner metadata before applying output-mode
// filtering, just as the slide splitter does.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(wrap: false),
)

// Keep the assertions before the filtered content so no skipped section can
// accidentally swallow the context expression itself.
#context {
  //no mode marker means "every mode", so it survives into the article
  assert.eq(query(<article-mode-slide-unlabelled>).len(), 1)
  //presentation-only, and we are compiling as article: dropped
  assert.eq(query(<article-mode-slide-presentation>).len(), 0)
  //article-only, and this is the article: kept
  assert.eq(query(<article-mode-slide-article>).len(), 1)
  //never appears in any output mode
  assert.eq(query(<article-mode-slide-never>).len(), 0)
}

#slide[unlabelled #metadata("keep") <article-mode-slide-unlabelled>]
#slide[presentation #metadata("drop") <article-mode-slide-presentation>] <touying:presentation>
#slide[article #metadata("keep") <article-mode-slide-article>] <touying:article>
#slide[never #metadata("drop") <article-mode-slide-never>] <touying:never>
