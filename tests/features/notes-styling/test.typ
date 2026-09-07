// #353: the speaker-note panel used to be hardcoded - grey, with a heading
// strip on top - and the only way to change it was to reimplement
// `config-methods(show-only-notes: ..)` wholesale, including its `cutout`
// protocol. These `config-common(note-*: ..)` options cover the styling cases
// without touching the method.
//
// This also carries the other half of the #219 change: now that a
// `config-page(background: ..)` is confined to the slide, `note-background` is
// how the note half gets a background of its own.
//
// Reference images are needed - every option here is about how the panel is
// painted, which introspection cannot see.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

#let slide-bg = rect(
  width: 100%,
  height: 100%,
  fill: gradient.linear(red, blue),
)

#let probe(..cfg) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(background: slide-bg),
    config-common(show-notes-on-second-screen: right, ..cfg),
    ..cfg.pos(),
  )
  touying-slide(
    self: self,
    [
      Slide content.

      #speaker-note[A speaker note, two lines long, to show the panel's
        text styling and inset.]
    ],
  )
})

= Speaker note styling

// The #353 ask: a plain panel with the note text and nothing else.
== Plain white panel, no header
#probe(
  note-header: none,
  note-background: white,
  note-inset: 24pt,
  note-setting: body => {
    set text(size: 16pt, fill: rgb("#333333"))
    body
  },
)

// A background given as content rather than a paint, plus a replaced header.
== Content background and custom header
#probe(
  note-background: rect(
    width: 100%,
    height: 100%,
    fill: gradient.linear(olive, aqua, angle: 45deg),
  ),
  note-header-background: navy,
  // Deliberately not `*bold*`: `show-strong-with-alert` would recolour it
  // with the theme's alert colour and obscure `note-setting`'s own fill.
  note-header: [My own header],
  note-setting: body => {
    set text(size: 18pt, fill: white)
    body
  },
)

// Header kept, but restyled and resized rather than removed.
== Restyled header strip
#probe(
  note-header-background: rgb("#204060"),
  note-header-height: 40pt,
  note-background: rgb("#fff8e7"),
  note-setting: body => {
    set text(size: 14pt, font: "Libertinus Serif")
    body
  },
)
