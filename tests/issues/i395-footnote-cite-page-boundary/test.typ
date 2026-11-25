// Regression test for the secondary case of #395: with the bibliography shown
// as footnotes, a citation whose footnote wraps to two lines failed with
// "citation could not be located" when it sat where the slide could hold the
// text but not the text plus that footnote.
//
// Compile-only tytanic test without `ref/*.png`: the regression is a compile
// error, so a plain `tt run` catches it.
//
// The footnote label used to contain the page number, and a label is part of
// an element's location. The full footnote did not fit, so the citation moved
// to the next page and got a new location; Typst then rendered it empty, the
// footnote shrank to one line and fitted on the earlier page again, and the
// layout never settled.
//
// The trigger is a narrow window of heights (240-254pt for this theme and
// entry), which moves with any change to the theme, the fonts or the entry, so
// each slide below puts the citation at a different height across a wider
// range. Keep the entries long enough that their footnotes wrap: a one-line
// footnote never triggers it.
//
// Each slide cites its own key. Several slides in the window citing the same
// key take more than five layout iterations to settle, because the label of
// the n-th footnote for a key comes from a query, which is empty in the first
// iteration; that case ends in a convergence warning, not in this error.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(show-bibliography-as-footnote: true))

#let heights = range(220, 276, step: 2)

#let bib-data = bytes(
  heights
    .map(height => (
      "@article{k"
        + str(height)
        + ", title = {A Deliberately Long Article Title So That the Full Citation in the Footnote Wraps Onto a Second Line}, author = {Doe, Jane and Roe, Richard and Moe, Mary and Poe, Edgar}, date = {2005-01}, journaltitle = {Journal of Examples}, volume = {4}, number = {1}, pages = {2--2}}"
    ))
    .join("\n"),
)

#for height in heights [
  == Slide at #height pt

  #v(height * 1pt)
  Text #cite(label("k" + str(height)))
]

#bibliography(bib-data, style: "ieee")
