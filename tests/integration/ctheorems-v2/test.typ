// ctheorems 2.x keeps its numbers in the states `thm-counters`, `thm-stored`
// and `thm-qed-done`. Touying rewinds them by key on every later subslide of a
// slide, so a theorem keeps its number while the slide is built up and the next
// slide continues from the last number, with no `frozen-states` needed here.
#import "/lib.typ": *
#import themes.simple: *
#import "@preview/ctheorems:2.0.0": *
#import thm-themes.ams: *

#show: thm-rules
#show: simple-theme.with(aspect-ratio: "16-9")
#set heading(numbering: "1.")

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
