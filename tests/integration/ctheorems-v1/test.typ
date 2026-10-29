// ctheorems 1.x keeps its numbers in the state `thm`. Remove together with
// the `state("thm", ...)` default in `src/configs.typ` when touying drops
// ctheorems 1.x support (planned for v0.9.0).
#import "/lib.typ": *
#import themes.simple: *
#import "@preview/ctheorems:1.1.3": *

#show: thmrules
#show: simple-theme.with(aspect-ratio: "16-9")
#set heading(numbering: "1.")

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let lemma = thmbox("theorem", "Lemma", fill: rgb("#eeeeff"))
#let proof = thmproof("proof", "Proof")

= Theorems

== Numbers stay put

#theorem[First] <first>

#pause

#lemma[Second]

#pause

#proof[Third]

== Numbers continue

#theorem[Fourth]

See @first.
