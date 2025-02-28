// ---------------------------------------------------------------------
// List, Enum, and Terms
// ---------------------------------------------------------------------


/// Align the list marker with the baseline of the first line of the list item.
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

/// Align the enum marker with the baseline of the first line of the enum item. It will only work when the enum item has a number like `1.`.
///
/// Usage: `#show: align-enum-marker-with-baseline`
///
/// -> content
#let align-enum-marker-with-baseline(body) = {
  let counting-symbols = "1aAiI一壹あいアイא가ㄱ*"
  let consume-regex = regex("[^" + counting-symbols + "]*[" + counting-symbols + "][^" + counting-symbols + "]*")

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

/// Scale the font size of the list items.
///
/// Usage: `#show: scale-list-items.with(scale: .75)`
///
/// - scale (int, float): The ratio of the font size of the current level to the font size of the upper level.
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

/// Make the list, enum, or terms nontight by default.
///
/// Usage: `#show list: nontight(list)`
///
/// -> content
#let nontight(lst) = {
  let fields = lst.fields()
  fields.remove("children")
  fields.tight = false
  return (lst.func())(..fields, ..lst.children)
}

/// Make the list, enum, and terms nontight by default.
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

/// Set the list marker to none for hide function.
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

#let bibliography-counter = counter("footer-bibliography-counter")
#let bibliography-state = state("footer-bibliography-state", ())
#let bibliography-map = state("footer-bibliography-map", (:))
#let bibliography-visited = state("footer-bibliography-visited", ())

/// Record the bibliography items.
///
/// -> content
#let record-bibliography(bibliography) = {
  show grid: it => {
    bibliography-state.update(
      range(it.children.len()).filter(i => calc.rem(i, 2) == 1).map(i => it.children.at(i).body),
    )
  }
  place(hide(bibliography))
}

/// Display the bibliography as footnote.
///
/// Usage: `#show: magic.bibliography-as-footnote.with(bibliography(title: none, "ref.bib"))`
///
/// - numbering (string): The numbering format of the bibliography in the footnote.
///
/// - record (boolean): Record the bibliography items or not. If you set it to false, you must call `#record-bibliography(bibliography)` by yourself.
///
/// - bibliography (bibliography): The bibliography argument. You should use the `bibliography` function to define the bibliography like `bibliography("ref.bib")`.
///
/// -> content
#let bibliography-as-footnote(numbering: "[1]", record: true, bibliography, body) = {
  show cite: it => (
    context {
      if it.key not in bibliography-visited.get() {
        box({
          place(hide(it))
          context {
            let bibitem = bibliography-state.final().at(bibliography-counter.get().at(0))
            footnote(numbering: numbering, bibitem)
            bibliography-map.update(map => {
              map.insert(str(it.key), bibitem)
              map
            })
          }
          bibliography-counter.step()
          bibliography-visited.update(visited => visited + (it.key,))
        })
      } else {
        footnote(numbering: numbering, context bibliography-map.final().at(str(it.key)))
      }
    }
  )

  // Record the bibliography items.
  if record {
    record-bibliography(bibliography)
  }

  body
}

/// Display the bibliography.
///
/// You can avoid `multiple bibliographies are not yet supported` error by using this function.
///
/// Usage: `#magic.bibliography()`
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
      ..range(bibitems.len()).map(i => (numbering("[1]", i + 1), bibitems.at(i))).flatten(),
    )
  }
}
