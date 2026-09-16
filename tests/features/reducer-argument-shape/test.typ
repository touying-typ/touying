// A reducer's call style determines how its parsed items are handed back to
// `reduce`: one array argument is an array-body, while multiple positional
// arguments remain variadic even when the individual elements are arrays.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== One array body stays one array

#touying-reducer(
  reduce: items => {
    assert.eq(items, ("array-a", "array-b"))
    []
  },
  cover: item => {
    assert.eq(type(item), array)
    assert.eq(item.len(), 1)
    item
  },
  ("array-a", pause, "array-b"),
)

== Direct arguments stay variadic, including array-valued elements

#touying-reducer(
  reduce: (..items) => {
    let items = items.pos()
    assert.eq(items, (("direct-a",), ("direct-b",)))
    []
  },
  cover: item => {
    assert.eq(type(item), array)
    item
  },
  ("direct-a",),
  pause,
  ("direct-b",),
)
