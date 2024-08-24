/// Align the list marker with the baseline of the first line of the list item.
///
/// Usage: `#show: align-list-marker-with-baseline`
#let align-list-marker-with-baseline(body) = {
  show list.item: it => {
    let current-marker = if type(list.marker) == array {
      list.marker.at(0)
    } else {
      list.marker
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
  show list: nontight(list)
  show enum: nontight(enum)
  show terms: nontight(terms)
  body
}