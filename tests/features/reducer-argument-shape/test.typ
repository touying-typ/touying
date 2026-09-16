// A reducer's call style determines how its parsed items are handed back to
// `reduce`: one array argument is an array-body, while multiple positional
// arguments remain variadic even when the individual elements are arrays.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== One array body stays one array

#touying-reducer(
  reduce: items => {
    //one array argument in, one array argument back out: `reduce` takes a
    //single parameter, not `..items`, and the pause is gone from the body
    assert.eq(items, ("array-a", "array-b"))
    []
  },
  cover: item => {
    //an item unpacked from the array body is handed back wrapped again, so a
    //package that iterates its body still sees whole elements
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
    //three positional arguments in, so the call stays variadic and the two
    //surviving elements arrive spread. Each is still the array it was written
    //as: being array-valued does not make this an array body
    assert.eq(items, (("direct-a",), ("direct-b",)))
    []
  },
  cover: item => {
    //a directly passed element is already whole, so it is covered as-is and
    //must not be wrapped a second time
    assert.eq(type(item), array)
    item
  },
  ("direct-a",),
  pause,
  ("direct-b",),
)
