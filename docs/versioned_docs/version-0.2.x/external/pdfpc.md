---
sidebar_position: 1
---

# Pdfpc

[pdfpc](https://pdfpc.github.io/) is a "Presenter Console with multi-monitor support for PDF files." This means you can use it to display slides in the form of PDF pages and it comes with some known excellent features, much like PowerPoint.

pdfpc has a JSON-formatted `.pdfpc` file that can provide additional information for PDF slides. While you can manually write this file, you can also manage it through Touying.


## Adding Metadata

Touying remains consistent with [Polylux](https://polylux.dev/book/external/pdfpc.html) to avoid conflicts between APIs.

For example, you can add notes using `#pdfpc.speaker-note("This is a note that only the speaker will see.")`.


## Pdfpc Configuration

To add pdfpc configurations, you can use

```typst
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
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
))
```

Add the corresponding configurations. Refer to [Polylux](https://polylux.dev/book/external/pdfpc.html) for specific configuration details.


## Exporting .pdfpc File

Assuming your document is `./example.typ`, you can export the `.pdfpc` file directly using:

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

With the compatibility of Touying and Polylux, you can make Polylux also support direct export by adding the following code:

```typst
#import "@preview/touying:0.2.1"

#locate(loc => touying.pdfpc.pdfpc-file(loc))
```