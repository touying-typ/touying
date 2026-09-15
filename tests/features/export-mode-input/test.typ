// `--input export-mode=...` is the one output switch a build script can use
// without editing its source. It must override even the low-level, legacy
// `article-mode` flag. CI compiles this once normally and once with
// `--input export-mode=presentation`.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(article-mode: true))

== Selected output

#article-only[article #label("export-input-article")]
#presentation-only[presentation #label("export-input-presentation")]

#context {
  let requested = utils.get-input(key: "export-mode")
  if requested == "presentation" {
    assert.eq(query(label("export-input-article")).len(), 0)
    assert.eq(query(label("export-input-presentation")).len(), 1)
  } else {
    assert.eq(query(label("export-input-article")).len(), 1)
    assert.eq(query(label("export-input-presentation")).len(), 0)
  }
}
