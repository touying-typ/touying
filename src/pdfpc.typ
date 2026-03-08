// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/blob/main/utils/pdfpc.typ
// Author: Andreas Kröpelin

/// Generate pdfpc metadata for the presentation. Called internally in the preamble when `enable-pdfpc` is `true`. Query the result with `typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc`.
///
/// -> content
#let pdfpc-file(loc) = {
  let arr = query(<pdfpc>).map(it => it.value)
  let (config, ..slides) = arr.split((t: "NewSlide"))
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
        page.label = str(item.v)
      } else if item.t == "Overlay" {
        page.overlay = item.v
        page.forcedOverlay = item.v > 0
      } else if item.t == "HiddenSlide" {
        page.hidden = true
      } else if item.t == "SaveSlide" {
        if "savedSlide" not in pdfpc {
          pdfpc.savedSlide = page.label - 1
        }
      } else if item.t == "EndSlide" {
        if "endSlide" not in pdfpc {
          pdfpc.endSlide = page.label - 1
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
