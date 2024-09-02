// ---------------------------------------------------------------------
// List, Enum, and Terms
// ---------------------------------------------------------------------


/// Align the list marker with the baseline of the first line of the list item.
///
/// Usage: `#show: align-list-marker-with-baseline`
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

/// Scale the font size of the list items.
///
/// Usage: `#show: scale-list-items.with(scale: .75)`
///
/// - `scale` (number): The ratio of the font size of the current level to the font size of the upper level.
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
#let nontight(lst) = {
  let fields = lst.fields()
  fields.remove("children")
  fields.tight = false
  return (lst.func())(..fields, ..lst.children)
}

/// Make the list, enum, and terms nontight by default.
///
/// Usage: `#show: nontight-list-enum-and-terms`
#let nontight-list-enum-and-terms(body) = {
  show list.where(tight: true): nontight
  show enum.where(tight: true): nontight
  show terms.where(tight: true): nontight
  body
}



// ---------------------------------------------------------------------
// Bibliography
// ---------------------------------------------------------------------

#let bibliography-counter = counter("footer-bibliography-counter")
#let bibliography-state = state("footer-bibliography-state", ())
#let bibliography-map = state("footer-bibliography-map", (:))

/// Display the bibliography as footnote.
///
/// Usage: `#show: magic.bibliography-as-footnote.with(bibliography("ref.bib"))`
///
/// Notice: You cannot use the same key twice in the same document, unless you use the escape option like `@key[-]`.
///
/// - numbering (string): The numbering format of the bibliography in the footnote.
///
/// - escape (content): The escape string which will be used to escape the cite key, in order to avoid the conflict of the same key.
///
/// - bibliography (bibliography): The bibliography argument. You should use the `bibliography` function to define the bibliography like `bibliography("ref.bib")`.
#let bibliography-as-footnote(numbering: "[1]", escape: [-], bibliography, body) = {
  show cite: it => if it.supplement != escape {
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
    })
  } else {
    footnote(numbering: numbering, context bibliography-map.final().at(str(it.key)))
  }

  // Record the bibliography items.
  {
    show grid: it => {
      bibliography-state.update(
        range(it.children.len()).filter(i => calc.rem(i, 2) == 1).map(i => it.children.at(i).body),
      )
    }
    place(hide(bibliography))
  }

  body
}

/// Display the bibliography.
///
/// You can avoid `multiple bibliographies are not yet supported` error by using this function.
///
/// Usage: `#magic.bibliography()`
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