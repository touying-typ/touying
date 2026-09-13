// A fn-wrapper decides its own visibility, so it escapes the surrounding pause
// zone instead of being covered by it. Inside a table-like container that was
// not honoured: the container worked out "would this be hidden?" before its
// second parse and then reused that stale answer, so the outer cover landed on
// top of a wrapper that had already revealed itself.
//
// Every DEEP below is `uncover("1-")`, visible from the first subslide, so each
// has to show on BOTH pages despite sitting after a `#pause`. `grid`, `table`
// and a grid nested one deeper are the three that regressed; the rest were
// already correct and are here so a later change cannot quietly break them.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

== Wrappers Behind A Pause

Visible from the start.
#pause

#grid(columns: 2, [#uncover("1-")[DEEP grid]], [x])

#table(columns: 2, [#uncover("1-")[DEEP table]], [x])

#stack(dir: ltr, [#uncover("1-")[DEEP stack]], [ x])

#columns(2)[#uncover("1-")[DEEP columns]]

- #uncover("1-")[DEEP list]

/ Term: #uncover("1-")[DEEP terms]

== Nested One Deeper

Visible from the start.
#pause

#block[#grid(columns: 1, [#uncover("1-")[DEEP nested]], [x])]
