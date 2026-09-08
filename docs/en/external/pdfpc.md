---
sidebar_position: 4
---

# Pdfpc

[pdfpc](https://pdfpc.github.io/) is a "Presenter Console with multi-monitor support for PDF files." This means you can use it to display slides in the form of PDF pages and it comes with some known excellent features, much like PowerPoint.

pdfpc has a JSON-formatted `.pdfpc` file that can provide additional information for PDF slides. While you can manually write this file, you can also manage it through Touying.
This works by adding metadata to the file which we then collect and extract into a `.pdfpc` file. All such functions are accessible under the module `pdfpc`.

Credits to [Polylux](https://polylux.dev/book/external/pdfpc.html) for most of the following.

## Speaker Notes
You can use the function `pdfpc.speaker-note(str|raw)` to add notes to your slides, that will only be visible in the speaker view in pdfpc.

## End slide

Sometimes the last slide in your presentation is not really the one you want to end with. Say, you have some bibliography or appendix for the sake of completeness after your "I thank my mom and everyone who believed in me"-slide.

With a simple pdfpc.end-slide inside any slide you can tell pdfpc that this is the last slide you usually want to show and hitting the End key will jump there.
Save a slide

## Save a slide
Similarly, there is a feature in pdfpc to bookmark a specific slide (and you can jump to it using Shift + M). In your Typst source, you can choose that slide by putting pdfpc.save-slide inside it.
Hide slides

## Hide slides
If you want to keep a certain slide in your presentation (just in case) but don't normally intend to show it, you can hide it inside pdfpc. It will be skipped during the presentation but it is still available in the overview. You can use pdfpc.hidden-slide in your Typst source to mark a slide as hidden.

## Pdfpc Configuration

To add pdfpc configurations, you can use

```typst
#pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
)
```

Add the corresponding configurations. Refer to [Polylux](https://polylux.dev/book/external/pdfpc.html) for specific configuration details.


## Exporting .pdfpc File

Assuming your document is `./example.typ`, you can export the `.pdfpc` file directly using:

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

With the compatibility of Touying and Polylux, you can make Polylux also support direct export by adding the following code:

```typst
#import "@preview/touying:0.7.4"

#context touying.pdfpc.pdfpc-file(here())
```

## Exporting .pdfpc Files as Bundle Assets

Since Typst 0.15, one compilation can emit a whole bundle of files, so the
`.pdfpc` file can be written next to the PDF without a second command. Add a
call to `#pdfpc.bundle-assets()` at the top level of your file, i.e. outside of
every `#document(..)`:

```typst
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#pdfpc.bundle-assets()

#document("deck.pdf", [
  #show: simple-theme

  == A slide
  #speaker-note[Only the speaker sees this.]
])
```

Compiling this with

```sh
typst compile --features bundle --format bundle --root . ./example.typ ./out
```

writes both `./out/deck.pdf` and `./out/deck.pdfpc`. Every PDF document of the
bundle gets its own `.pdfpc` file, named after the document and containing only
that presentation's notes and configuration. Documents without pdfpc metadata
and non-PDF documents are skipped, and outside of a bundle export the call does
nothing at all - so you can leave `#pdfpc.bundle-assets()` in a file that you
also compile to a plain PDF. Note that this is true of the call itself; the
`#document(..)` wrapper above is bundle-only, and Typst rejects it with
`constructing a document is only supported in the bundle target` when you
compile to a PDF.

Note that bundle export is still experimental, so Typst warns about it and its
behaviour may change.
