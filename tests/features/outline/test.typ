#import "/lib.typ": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#show: simple-theme

#set heading(numbering: numbly("{1}.", default: "1.1"))

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= First Section

== First Subsection

Content of first subsection.

== Second Subsection  

Content of second subsection.

= Second Section

== Third Subsection

Content of third subsection.