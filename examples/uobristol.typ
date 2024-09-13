#import "../lib.typ": *
#import themes.uobristol: *

#import "@preview/numbly:0.1.0": numbly

#show: uobristol-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.city,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide([Outline])

= First Section

A slide without a title but with some *important* information.

=== Heading of level next to the "slide level"

If the "slide level" is 2, the level-2 heading will be renderred as a new slide, and the level-3 heading will be shown as a special heading.

==== Other headings are renderred as normal

Headings of levels greater than $"slide level" + 1$ are shown as normal.

=== Highlight

The `highlight` is changed to show text like #highlight[this].

---

=== Tables

The lines of tables are shown with the primary color.

#table(
  columns: (1fr, ) * 3,
  align: center,
  inset: .5em,
  table.header[*Column1*][*Column2*][*Column2*],
  [Content], [Content], [Content],
  [Content], [Content], [Content],
)

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

A slide with equation:

$ x_(n+1) = (x_n + a/x_n) / 2 $

#lorem(200)

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

We can use `#pause` to #pause display something later.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `#let s = (s.math.show-notes-on-second-screen)(self: s, right)`
]

#show: appendix

= Appendix

Please pay attention to the current slide number.