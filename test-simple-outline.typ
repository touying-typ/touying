#import "/lib.typ": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#show: simple-theme

#set heading(numbering: numbly(none, "{2}.", default: "1.1"))

#outline(title: none, indent: 1em)

= T1

== S1
C1

== S2
C2

== S3
C3

== S4
C4
