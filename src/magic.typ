// ---------------------------------------------------------------------
// Warning
// ---------------------------------------------------------------------


/// Display a warning message with `set text(font: ..)` magic.
///
/// - message (str): The warning message.
///
/// -> content
#let warning(prefix: "[touying] ", message) = {
  let delete-old-warning = range(21).map(i => "\u{0008}").sum()
  set text(font: delete-old-warning + prefix + message)
}

// ---------------------------------------------------------------------
// List, Enum, and Terms
// ---------------------------------------------------------------------


/// Apply as a show rule to vertically align list markers with the baseline of the first line of each list item. This prevents markers from appearing too high when list items have tall content.
///
/// Usage: `#show: align-list-marker-with-baseline`
///
/// -> content
#let align-list-marker-with-baseline(body) = {
  show list.item: it => {
    let current-marker = {
      set text(fill: text.fill)
      if type(list.marker) == array {
        list.marker.at(0)
      } else {
        list.marker
      }
    }
    let hanging-indent = measure(current-marker).width + .6em + .3pt
    set terms(hanging-indent: hanging-indent)
    if type(list.marker) == array {
      terms.item(
        current-marker,
        {
          // set the value of list.marker in a loop
          set list(marker: list.marker.slice(1) + (list.marker.at(0),))
          it.body
        },
      )
    } else {
      terms.item(current-marker, it.body)
    }
  }
  body
}

/// Apply as a show rule to vertically align enum markers with the baseline of the first line of each enum item. Only works for numeric markers (e.g. `1.`).
///
/// Usage: `#show: align-enum-marker-with-baseline`
///
/// -> content
#let align-enum-marker-with-baseline(body) = {
  let counting-symbols = "1aAiI一壹あいアイא가ㄱ*"
  let consume-regex = regex(
    "[^"
      + counting-symbols
      + "]*["
      + counting-symbols
      + "][^"
      + counting-symbols
      + "]*",
  )

  show enum.item: it => {
    if it.number == none {
      return it
    }
    let new-numbering = if type(enum.numbering) == function or enum.full {
      numbering.with(enum.numbering, it.number)
    } else {
      enum.numbering.trim(consume-regex, at: start, repeat: false)
    }
    let current-number = numbering(enum.numbering, it.number)
    set terms(hanging-indent: 1.2em)
    terms.item(
      strong(delta: -strong.delta, numbering(enum.numbering, it.number)),
      {
        if new-numbering != "" {
          set enum(numbering: new-numbering)
          it.body
        } else {
          it.body
        }
      },
    )
  }

  body
}

/// Scale the font size of nested list, enum, and terms items.
///
/// Usage: `#show: scale-list-items.with(scale: .75)`
///
/// - scale (int, float): The font size ratio of the current nesting level relative to the parent. Default is `.75`.
///
/// - body (content): The content to apply the scaling to.
///
/// -> content
#let scale-list-items(
  scale: .75,
  body,
) = {
  show list.where().or(enum.where().or(terms)): it => {
    show list.where().or(enum.where().or(terms)): set text(scale * 1em)
    it
  }
  body
}

/// Convert a single tight list, enum, or terms element to non-tight (with spacing between items). For use in show rules.
///
/// Usage: `#show list: nontight(list)`
///
/// - lst (content): A list, enum, or terms element to make non-tight.
///
/// -> content
#let nontight(lst) = {
  let fields = lst.fields()
  fields.remove("children")
  fields.tight = false
  return (lst.func())(..fields, ..lst.children)
}

/// Apply as a show rule to make all lists, enumerations, and term lists use non-tight spacing by default (adds spacing between items).
///
/// Usage: `#show: nontight-list-enum-and-terms`
///
/// -> content
#let nontight-list-enum-and-terms(body) = {
  show list.where(tight: true): nontight
  show enum.where(tight: true): nontight
  show terms.where(tight: true): nontight
  body
}

/// Apply as a show rule to suppress list markers and enum numbering inside `#hide(...)` calls. This prevents phantom markers from taking up space in covered content.
///
/// Usage: `#show: show-hide-set-list-marker-none`
///
/// -> content
#let show-hide-set-list-marker-none(body) = {
  show hide: it => {
    set list(marker: none)
    set enum(numbering: (..nums) => none)

    it
  }
  body
}



// ---------------------------------------------------------------------
// Bibliography
// ---------------------------------------------------------------------

#let bibliography-state = state("footer-bibliography-state", ())
#let bibliography-visited = state("footer-bibliography-visited", ())

/// Display bibliography citations as footnotes. Place `#place(hide(bibliography(...)))` at the end of the document to register the bibliography entries.
///
/// Usage: `#show: magic.bibliography-as-footnote.with(bibliography(title: none, "ref.bib"))`
///
/// - numbering (str): The numbering format for footnote citations. Default is `"[1]"`.
///
/// - bibliography (bibliography): The bibliography element, e.g. `bibliography("ref.bib")`.
///
/// -> content
#let bibliography-as-footnote(
  numbering: "[1]",
  bibliography,
  body,
) = {
  show cite.where(form: "normal"): it => (
    context {
      let label-str = str(here().page()) + str(it.key)
      let bibitem = {
        show: body => {
          show regex("^\[\d+\]\s"): it => ""
          body
        }
        cite(it.key, form: "full")
      }
      if it.key not in bibliography-visited.get() {
        bibliography-state.update(x => (..x, bibitem))
        bibliography-visited.update(visited => visited + (it.key,))
      }
      box({
        if query(selector(label(label-str)).before(here())).len() > 0 {
          [#footnote(label(label-str), numbering: numbering)]
        } else {
          [#footnote(numbering: numbering, bibitem)#label(label-str)]
        }
      })
    }
  )

  body
}

/// Display the collected bibliography entries. Avoids the "multiple bibliographies are not yet supported" error by rendering entries gathered by `bibliography-as-footnote`.
///
/// Usage: `#magic.bibliography()`
///
/// - title (str, auto, none): The heading for the bibliography section. When `auto`, uses a language-appropriate title. When `none`, no heading is shown. Default is `auto`.
///
/// -> content
#let bibliography(title: auto) = {
  context {
    let title = title
    let bibitems = bibliography-state.final()
    if title == auto {
      if text.lang == "zh" {
        title = "参考文献"
      } else {
        title = "Bibliography"
      }
    }
    if title != none {
      heading(title)
      v(.45em)
    }
    grid(
      columns: (auto, 1fr),
      column-gutter: .7em,
      row-gutter: 1.2em,
      ..range(bibitems.len())
        .map(i => (numbering("[1]", i + 1), bibitems.at(i)))
        .flatten(),
    )
  }
}
