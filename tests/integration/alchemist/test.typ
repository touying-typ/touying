#import "/lib.typ": *
#import themes.simple: *
#import "@preview/alchemist:0.2.0"

// alchemist 0.2.0 exposes `touying-reducer-bindings` in the format of touying
// 0.7 (arrays of names). touying-reduce does not take those, so it must fall
// back to the bindings it has for the package's name.
#let skeletize = touying-reduce.with(alchemist)

#show: simple-theme.with(aspect-ratio: "16-9")

== Alchemist Animation

#slide[
  #skeletize({
    import alchemist: *
    fragment("A")
    single()
    (pause,)
    fragment("B")
  })
]
