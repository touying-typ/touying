---
sidebar_position: 10
---

# Speaker Notes

A speaker note is content meant for you, not for the audience. You write it inline, next to the slide it belongs to, and Touying keeps it out of the slides themselves.

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#show: simple-theme

== Photosynthesis

Light in, sugar out.

#speaker-note[
  - Recap respiration from the previous section.
  - Time check: we should be at the 10 minute mark.
]
```

The note leaves no trace on the slide. That is the point: the same source produces the slides your audience sees and, separately, the material only you see.

## Where notes actually go

A note has three possible destinations, and they are independent — you can use one, two, or all three from the same document.

| destination | how | who sees it |
| --- | --- | --- |
| pdfpc metadata | on by default (`enable-pdfpc: true`) | your presenter tool |
| a second screen | `config-common(show-notes-on-second-screen: ..)` | you, on the second display |
| a presenter view | `config-common(show-only-notes: true)` | you, in a separate export |

## Second screen

`show-notes-on-second-screen` doubles the page along one axis and puts the notes in the half that opens up. The slide keeps its own dimensions, so the left half is still a normal slide — you present that half full-screen and read the other half yourself.

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-notes-on-second-screen: right),
)
```

`top`, `bottom`, `left` and `right` are all accepted.

A `config-page(background: ..)` belongs to the slide and covers only the slide's own half. The notes half is styled separately — see [Styling the panel](#styling-the-panel).

## Presenter view

`show-only-notes: true` swaps what is on the page. The note becomes the page's main content, and the whole slide is shrunk into a preview in the corner.

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-only-notes: true),
)
```

Two things about it are easy to get wrong.

**It does not drop anything.** The page count is identical to a normal compile, subslides included — every page is still there, it just shows the note instead of the slide. So page 7 of your presenter export lines up with page 7 of your slides, which is what makes the two usable side by side.

**It is a second export, not a mode you present from.** You produce two PDFs from one source: the normal one for the projector, and a presenter one with the flag set. There is no built-in command-line switch for it, so gate it yourself if you want to avoid editing the file between compiles:

```typst
#let notes-export = sys.inputs.at("notes", default: none) != none

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-only-notes: notes-export),
)
```

```sh
typst compile slides.typ slides.pdf
typst compile slides.typ --input notes=1 notes.pdf
```

## Restricting a note to some subslides

By default a note follows the pause position it is written at, exactly like ordinary content: a note after `#pause` appears only from that subslide onward. `subslide:` overrides that.

```typst
// only on subslide 2
#speaker-note(subslide: 2)[Mention the caveat here.]

// on every subslide, regardless of where it sits
#speaker-note(subslide: none)[Keep an eye on the clock.]
```

The note body may itself contain `#pause`, revealing parts of the note progressively across subslides.

## Markdown notes for pdfpc

pdfpc renders notes as Markdown. `mode` controls how Touying serialises a note into the pdfpc file — you still write ordinary Typst either way:

```typst
#speaker-note(mode: "md")[
  - a bullet
  - *bold*
]
```

With `mode: "typ"` (the default) that `*bold*` is written out as `*bold*`; with `mode: "md"` it becomes `**bold**`, which is what pdfpc expects. Headings, links and emphasis are translated the same way.

## Exporting for a presenter tool

With `enable-pdfpc: true` (the default) Touying records every note in the document's pdfpc metadata. Extracting it as a `.pdfpc` file next to your PDF gives tools like [pdfpc](https://pdfpc.github.io/) and [pympress](https://github.com/Cimbali/pympress) their notes, timings and slide structure.

Since Typst 0.15 you can have the file written for you during a bundle export instead of running a second command — see [pdfpc](../external/pdfpc.md) for both routes.

## Styling the panel

The panel that shows your notes — on a second screen or in the presenter view — is drawn by the theme, through `config-common(notes-fn: ..)`. Every bundled theme sets it, so the notes come out looking like the rest of the theme.

The default is `touying-notes`, which handles the layout and leaves the styling to you: `header`, `header-fill`, `fill`, `note-setting` and `preview-setting`. Writing one for your own theme is covered in [Build Your Own Theme](build-your-own-theme.md).
