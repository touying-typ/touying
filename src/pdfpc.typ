// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/blob/main/utils/pdfpc.typ
// Author: Andreas Kröpelin

#import "bundle.typ"

/// Generate pdfpc metadata for the presentation. Called internally in the preamble when `enable-pdfpc` is `true`.
///
/// The result carries the `<pdfpc-file>` label. Turn it into a `.pdfpc` file either with `#pdfpc.bundle-assets()` in a bundle export, or with the shell command `typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc`.
///
/// - loc (location): A location inside the presentation. It tells the slides of this presentation apart from those of the other documents in a bundle export.
///
/// -> content
#let pdfpc-file(loc) = {
  // A bundle export compiles several presentations at once and introspection
  // sees all of them, so a plain `query(<pdfpc>)` would merge the notes and
  // slide markers of every presentation into every `.pdfpc` file (see #408).
  // Ask for the markers of our own document instead.
  let own-document = bundle.current-document-location(loc)
  let pdfpc-selector = bundle.within-current-document(<pdfpc>, loc)
  let arr = query(pdfpc-selector).map(it => it.value)
  let (config, ..slides) = arr.split((t: "NewSlide"))
  // `Idx` restarts at 0 in every document of a bundle, because physical pages
  // do, but the slide counter behind `LogicalSlide` is shared across the whole
  // bundle. pdfpc reads `label` as a logical slide index into *this* PDF
  // (`savedSlide` and `endSlide` are derived from it), so the labels of the
  // second presentation must be rebased onto its own first slide. Outside of
  // bundle export there is nothing to rebase, and we must not: the slide
  // counter may have been deliberately started elsewhere than 1, in which case
  // the printed slide numbers would no longer match the `.pdfpc` file.
  let label-offset = if own-document == none {
    0
  } else {
    let first-slide = slides.at(0, default: ())
    let first-label = first-slide.find(it => it.t == "LogicalSlide")
    if first-label == none { 0 } else { first-label.v - 1 }
  }
  let pdfpc = (
    pdfpcFormat: 2,
    disableMarkdown: false,
  )
  for item in config {
    pdfpc.insert(lower(item.t.at(0)) + item.t.slice(1), item.v)
  }
  let pages = ()
  for slide in slides {
    let page = (
      idx: 0,
      label: 1,
      overlay: 0,
      forcedOverlay: false,
      hidden: false,
    )
    for item in slide {
      if item.t == "Idx" {
        page.idx = item.v
      } else if item.t == "LogicalSlide" {
        page.label = str(item.v - label-offset)
      } else if item.t == "Overlay" {
        page.overlay = item.v
        page.forcedOverlay = item.v > 0
      } else if item.t == "HiddenSlide" {
        page.hidden = true
      } else if item.t == "SaveSlide" {
        if "savedSlide" not in pdfpc {
          pdfpc.savedSlide = int(page.label) - 1
        }
      } else if item.t == "EndSlide" {
        if "endSlide" not in pdfpc {
          pdfpc.endSlide = int(page.label) - 1
        }
      } else if item.t == "Note" {
        page.note = if "note" in page {
          page.note + "\n\n" + item.v
        } else {
          item.v
        }
      } else {
        pdfpc.insert(lower(item.t.at(0)) + item.t.slice(1), item.v)
      }
    }
    pages.push(page)
  }
  pdfpc.insert("pages", pages)
  [#metadata(pdfpc)<pdfpc-file>]
}

/// Write the pdfpc metadata of every presentation in a bundle export to a `.pdfpc` file next to it.
///
/// Since Typst 0.15 a single compilation can emit a whole bundle of files, which is how a `.pdfpc` file can be produced without the extra `typst query` invocation documented on `pdfpc-file`:
///
/// ```sh
/// typst compile --features bundle --format bundle --root . ./example.typ ./out
/// ```
///
/// Call this at the top level of the file, i.e. *outside* of every `#document(..)`: an asset belongs to the bundle rather than to one of its documents, and Typst rejects `asset(..)` inside a document body. The call may sit before or after the documents; introspection sees the whole bundle either way.
///
/// Each PDF document of the bundle that carries pdfpc metadata (every touying presentation with `enable-pdfpc: true`) gets one `.pdfpc` file, named after the document itself: `slides/deck.pdf` is accompanied by `slides/deck.pdfpc`. Documents without pdfpc metadata are skipped, and so are non-PDF documents, because pdfpc presents PDFs.
///
/// Outside of a bundle export this does nothing at all, so a file containing the call still compiles to a plain PDF. That applies to this call only - `#document(..)` itself is bundle-only and Typst rejects it in any other target.
///
/// Example:
///
/// ```typ
/// #import "@preview/touying:0.7.4": *
/// #import themes.simple: *
///
/// #pdfpc.bundle-assets()
///
/// #document("deck.pdf", [
///   #show: simple-theme
///
///   == A slide
///   #speaker-note[Only the speaker sees this.]
/// ])
/// ```
///
/// - pretty (bool): Whether to pretty-print the JSON. Default is `true`.
///
/// -> content
#let bundle-assets(pretty: true) = context {
  // `asset` exists only in the bundle target, and erroring out anywhere else
  // would make the call unusable in a file that is also compiled to a PDF.
  if target() == "bundle" {
    for doc in query(document) {
      // A `.pdfpc` file next to an HTML page or a PNG would be meaningless,
      // and skipping those also keeps two documents that share a stem
      // (`deck.pdf` and `deck.png`) from claiming the same asset path.
      let is-pdf = if doc.format == auto {
        lower(doc.path).ends-with(".pdf")
      } else {
        doc.format == "pdf"
      }
      if not is-pdf {
        continue
      }
      // Re-use the metadata the presentation itself assembled, so that the
      // scoping and the pdfpc format live in exactly one place. There is one
      // `<pdfpc-file>` per presentation; should a user have emitted further
      // ones by hand, the last one wins, as with `typst query --one`.
      let files = query(selector(<pdfpc-file>).within(doc.location()))
      if files.len() == 0 {
        continue
      }
      // `document.path` is bundle-absolute (`/slides/deck.pdf`) and `asset`
      // reads paths in that same form, so this lands next to the PDF.
      let path = doc.path.replace(regex("\\.[^./]*$"), "") + ".pdfpc"
      // A trailing newline keeps the emitted file a well-formed text file.
      let data = json.encode(files.last().value, pretty: pretty) + "\n"
      asset(path, data)
    }
  }
}


/// Emit a raw speaker note string for the current slide into the pdfpc metadata. Called internally by `utils.speaker-note`.
///
/// -> content
#let speaker-note(text) = {
  let text = if type(text) == str {
    text
  } else if type(text) == content and text.func() == raw {
    text.text.trim()
  } else {
    panic("A note must either be a string or a raw block")
  }
  [ #metadata((t: "Note", v: text)) <pdfpc> ]
}

#let end-slide = [
  #metadata((t: "EndSlide")) <pdfpc>
]

#let save-slide = [
  #metadata((t: "SaveSlide")) <pdfpc>
]

#let hidden-slide = [
  #metadata((t: "HiddenSlide")) <pdfpc>
]


/// Configuration for the pdfpc export. You can export the pdfpc file by shell command `typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc`.
///
/// Example:
///
/// ```typ
/// #pdfpc.config(
///   duration-minutes: 30,
///   start-time: datetime(hour: 14, minute: 10, second: 0),
///   end-time: datetime(hour: 14, minute: 40, second: 0),
///   last-minutes: 5,
///   note-font-size: 12,
///   disable-markdown: false,
///   default-transition: (
///     type: "push",
///     duration-seconds: 2,
///     angle: ltr,
///     alignment: "vertical",
///     direction: "inward",
///   ),
/// )
/// ```
///
/// - duration-minutes (int): The duration of the presentation in minutes.
///
/// - start-time (datetime): The start time of the presentation.
///
/// - end-time (datetime): The end time of the presentation.
///
/// - last-minutes (int): The number of minutes to show the last slide.
///
/// - note-font-size (float): The font size of the speaker notes.
///
/// - disable-markdown (bool): A flag to disable markdown in the speaker notes.
///
/// - default-transition (dictionary, none): The default slide transition. A dictionary with optional keys: `type` (str, e.g. `"push"`), `duration-seconds` (int), `angle` (direction, e.g. `ltr`), `alignment` (str, `"horizontal"` or `"vertical"`), `direction` (str, `"inward"` or `"outward"`). Default is `none`.
///
/// -> content
#let config(
  duration-minutes: none,
  start-time: none,
  end-time: none,
  last-minutes: none,
  note-font-size: none,
  disable-markdown: false,
  default-transition: none,
) = {
  if duration-minutes != none {
    [ #metadata((t: "Duration", v: duration-minutes)) <pdfpc> ]
  }

  let _time-config(time, msg-name, tag-name) = {
    let time = if type(time) == datetime {
      time.display("[hour padding:zero repr:24]:[minute padding:zero]")
    } else if type(time) == str {
      time
    } else {
      panic(
        msg-name
          + " must be either a datetime or a string in the HH:MM format.",
      )
    }

    [ #metadata((t: tag-name, v: time)) <pdfpc> ]
  }

  if start-time != none {
    _time-config(start-time, "Start time", "StartTime")
  }

  if end-time != none {
    _time-config(end-time, "End time", "EndTime")
  }

  if last-minutes != none {
    [ #metadata((t: "LastMinutes", v: last-minutes)) <pdfpc> ]
  }

  if note-font-size != none {
    [ #metadata((t: "NoteFontSize", v: note-font-size)) <pdfpc> ]
  }

  [ #metadata((t: "DisableMarkdown", v: disable-markdown)) <pdfpc> ]

  if default-transition != none {
    let dir-to-angle(dir) = if dir == ltr {
      "0"
    } else if dir == rtl {
      "180"
    } else if dir == ttb {
      "90"
    } else if dir == btt {
      "270"
    } else {
      panic("angle must be a direction (ltr, rtl, ttb, or btt)")
    }

    let transition-str = (
      default-transition.at("type", default: "replace")
        + ":"
        + str(
          default-transition.at("duration-seconds", default: 1),
        )
        + ":"
        + dir-to-angle(default-transition.at("angle", default: rtl))
        + ":"
        + default-transition.at(
          "alignment",
          default: "horizontal",
        )
        + ":"
        + default-transition.at("direction", default: "outward")
    )

    [ #metadata((t: "DefaultTransition", v: transition-str)) <pdfpc> ]
  }
}
