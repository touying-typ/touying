#import "pdfpc.typ"
#import "utils.typ"
#import "magic.typ"
#import "core.typ": touying-slide-wrapper, touying-slide, slide

#let _default = metadata((kind: "touying-default"))

#let _get-dict-without-default(dict) = {
  let new-dict = (:)
  for (key, value) in dict.pairs() {
    if value != _default {
      new-dict.insert(key, value)
    }
  }
  return new-dict
}

/// The private configurations of the theme.
#let config-store(..args) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (store: args.named())
}


#let _default-frozen-states = (
  // ctheorems state
  state("thm",
    (
      "counters": ("heading": ()),
      "latest": ()
    )
  ),
)

#let _default-frozen-counters = (
  counter(heading),
  counter(math.equation),
  counter(figure.where(kind: table)),
  counter(figure.where(kind: image)),
)

#let _default-preamble = self => {
  if self.at("enable-mark-warning", default: true) {
    context {
      let marks = query(<touying-temporary-mark>)
      if marks.len() > 0 {
        let page-num = marks.at(0).location().page()
        let kind = marks.at(0).value.kind
        panic("Unsupported mark `" + kind + "` at page " + str(page-num) + ". You can't use it inside some functions like `context`. You may want to use the callback-style `uncover` function instead.")
      }
    }
  }
  if self.at("enable-pdfpc", default: true) {
    context pdfpc.pdfpc-file(here())
  }
  if self.at("show-bibliography-as-footnote", default: none) != none {
    let args = self.at("show-bibliography-as-footnote", default: none)
    let bibliography = if type(args) == dictionary {
      args.at("bibliography")
    } else {
      args
    }
    magic.record-bibliography(bibliography)
  }
}

#let _default-page-preamble = self => {
  if self.at("reset-footnote-number-per-slide", default: true) {
    counter(footnote).update(0)
  }
  if self.at("reset-page-counter-to-slide-counter", default: true) {
    context counter(page).update(utils.slide-counter.get())
  }
  if self.at("enable-pdfpc", default: true) {
    context [
      #metadata((t: "NewSlide")) <pdfpc>
      #metadata((t: "Idx", v: here().page() - 1)) <pdfpc>
      #metadata((t: "Overlay", v: self.subslide - 1)) <pdfpc>
      #metadata((t: "LogicalSlide", v: utils.slide-counter.get().first())) <pdfpc>
    ]
  }
}

#let _default-slide-preamble = self => {
  if self.at("reset-footnote-number-per-slide", default: true) {
    counter(footnote).update(0)
  }
}


/// The common configurations of the slides.
///
/// - handout (boolean): Whether to enable the handout mode. It retains only the last subslide of each slide in handout mode. Default is `false`.
///
/// - slide-level (int): The level of the slides. Default is `2`, which means the level 1 and 2 headings will be treated as slides.
///
/// - slide-fn (function): The function to create a new slide.
///
/// - new-section-slide-fn (function): The function to create a new slide for a new section. Default is `none`.
///
/// - new-subsection-slide-fn (function): The function to create a new slide for a new subsection. Default is `none`.
///
/// - new-subsubsection-slide-fn (function): The function to create a new slide for a new subsubsection. Default is `none`.
///
/// - new-subsubsubsection-slide-fn (function): The function to create a new slide for a new subsubsubsection. Default is `none`.
///
/// - receive-body-for-new-section-slide-fn (boolean): Whether to receive the body for the new section slide function. Default is `true`.
///
/// - receive-body-for-new-subsection-slide-fn (boolean): Whether to receive the body for the new subsection slide function. Default is `true`.
///
/// - receive-body-for-new-subsubsection-slide-fn (boolean): Whether to receive the body for the new subsubsection slide function. Default is `true`.
///
/// - receive-body-for-new-subsubsubsection-slide-fn (boolean): Whether to receive the body for the new subsubsubsection slide function. Default is `true`.
///
/// - show-strong-with-alert (boolean): Whether to show strong with alert. Default is `true`.
///
/// - datetime-format (auto, string): The format of the datetime. Default is `auto`.
///
/// - appendix (boolean): Is touying in the appendix mode. The last-slide-counter will be frozen in the appendix mode. Default is `false`.
///
/// - freeze-slide-counter (boolean): Whether to freeze the slide counter. Default is `false`.
///
/// - zero-margin-header (boolean): Whether to show the full header (with negative padding). Default is `true`.
///
/// - zero-margin-footer (boolean): Whether to show the full footer (with negative padding). Default is `true`.
///
/// - auto-offset-for-heading (boolean): Whether to add an offset relative to slide-level for headings. Default is `true`.
///
/// - enable-pdfpc (boolean): Whether to add `<pdfpc-file>` label for querying. Default is `true`.
///
///   You can export the .pdfpc file directly using: `typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc`
///
/// - enable-mark-warning (boolean): Whether to enable the mark warning. Default is `true`.
///
/// - reset-page-counter-to-slide-counter (boolean): Whether to reset the page counter to the slide counter. Default is `true`.
///
/// - show-notes-on-second-screen (none, alignment): Whether to show the speaker notes on the second screen. Default is `none`.
///
///   Currently, the alignment can be `none`, `bottom`, and `right`.
///
/// - horizontal-line-to-pagebreak (boolean): Whether to convert horizontal lines to page breaks. Default is `true`.
///
///   You can use markdown-like syntax `---` to divide slides.
///
/// - reset-footnote-number-per-slide (boolean): Whether to reset the footnote number per slide. Default is `true`.
///
/// - nontight-list-enum-and-terms (boolean): Whether to make `tight` argument always be `false` for list, enum, and terms. Default is `false`.
///
/// - align-list-marker-with-baseline (boolean): Whether to align the list marker with the baseline. Default is `false`.
///
/// - align-enum-marker-with-baseline (boolean): Whether to align the enum marker with the baseline. Default is `false`. It will only work when the enum item has a number like `1.`.
///
/// - scale-list-items (none, float): Whether to scale the list items recursively. For example, `scale-list-items: 0.8` will scale the list items by 0.8. Default is `none`.
///
/// - enable-frozen-states-and-counters (boolean): Whether to enable the frozen states and counters. It is useful for equations, figures, and theorems. Default is `true`.
///
/// - show-hide-set-list-marker-none (boolean): Whether to set the list marker to none for hide function. Default is `true`.
///
/// - show-bibliography-as-footnote (boolean): Whether to show the bibliography as footnote. Default is `none`.
///
///   It receives a bibliography function like `bibliography(title: none, "ref.bib")`, or a dict like `(numbering: "[1]", bibliography: bibliography(title: none, "ref.bib"))`.
///
/// - frozen-states (array): The frozen states for the frozen states and counters. Default is `()`.
///
/// - default-frozen-states (function): The default frozen states for the frozen states and counters. Default is state for `ctheorems` package.
///
/// - frozen-counters (array): The frozen counters for the frozen states and counters. You can pass some counters like `(counter(math.equation),)`. Default is `()`.
///
/// - default-frozen-counters (array): The default frozen counters for the frozen states and counters. The default value is `(counter(math.equation), counter(figure.where(kind: table)), counter(figure.where(kind: image)))`.
///
/// - label-only-on-last-subslide (array): We only label some contents in the last subslide, which is useful for ref equations, figures, and theorems with multiple subslides. Default is `(figure, math.equation)`.
///
/// - preamble (function): The function to run before each slide. Default is `none`.
///
/// - default-preamble (function): The default preamble for each slide. Default is a function to check the mark warning and add pdfpc file.
///
/// - slide-preamble (function): The function to run before each slide. Default is `none`.
///
/// - default-slide-preamble (function): The default preamble for each slide. Default is `none`.
///
/// - subslide-preamble (function): The function to run before each subslide. Default is `none`.
///
/// - default-subslide-preamble (function): The default preamble for each subslide. Default is `none`.
///
/// - page-preamble (function): The function to run before each page. Default is `none`.
///
/// - default-page-preamble (function): The default preamble for each page. Default is a function to reset the footnote number per slide and reset the page counter to the slide counter.
#let config-common(
  handout: _default,
  slide-level: _default,
  slide-fn: _default,
  new-section-slide-fn: _default,
  new-subsection-slide-fn: _default,
  new-subsubsection-slide-fn: _default,
  new-subsubsubsection-slide-fn: _default,
  receive-body-for-new-section-slide-fn: _default,
  receive-body-for-new-subsection-slide-fn: _default,
  receive-body-for-new-subsubsection-slide-fn: _default,
  receive-body-for-new-subsubsubsection-slide-fn: _default,
  show-strong-with-alert: _default,
  datetime-format: _default,
  appendix: _default,
  freeze-slide-counter: _default,
  zero-margin-header: _default,
  zero-margin-footer: _default,
  auto-offset-for-heading: _default,
  enable-pdfpc: _default,
  enable-mark-warning: _default,
  reset-page-counter-to-slide-counter: _default,
  // some black magics for better slides writing,
  // maybe will be deprecated in the future
  enable-frozen-states-and-counters: _default,
  frozen-states: _default,
  default-frozen-states: _default,
  frozen-counters: _default,
  default-frozen-counters: _default,
  label-only-on-last-subslide: _default,
  preamble: _default,
  default-preamble: _default,
  slide-preamble: _default,
  default-slide-preamble: _default,
  subslide-preamble: _default,
  default-subslide-preamble: _default,
  page-preamble: _default,
  default-page-preamble: _default,
  show-notes-on-second-screen: _default,
  horizontal-line-to-pagebreak: _default,
  reset-footnote-number-per-slide: _default,
  nontight-list-enum-and-terms: _default,
  align-list-marker-with-baseline: _default,
  align-enum-marker-with-baseline: _default,
  scale-list-items: _default,
  show-hide-set-list-marker-none: _default,
  show-bibliography-as-footnote: _default,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return _get-dict-without-default((
    handout: handout,
    slide-level: slide-level,
    slide-fn: slide-fn,
    new-section-slide-fn: new-section-slide-fn,
    new-subsection-slide-fn: new-subsection-slide-fn,
    new-subsubsection-slide-fn: new-subsubsection-slide-fn,
    new-subsubsubsection-slide-fn: new-subsubsubsection-slide-fn,
    receive-body-for-new-section-slide-fn: receive-body-for-new-section-slide-fn,
    receive-body-for-new-subsection-slide-fn: receive-body-for-new-subsection-slide-fn,
    receive-body-for-new-subsubsection-slide-fn: receive-body-for-new-subsubsection-slide-fn,
    receive-body-for-new-subsubsubsection-slide-fn: receive-body-for-new-subsubsubsection-slide-fn,
    show-strong-with-alert: show-strong-with-alert,
    datetime-format: datetime-format,
    appendix: appendix,
    freeze-slide-counter: freeze-slide-counter,
    zero-margin-header: zero-margin-header,
    zero-margin-footer: zero-margin-footer,
    auto-offset-for-heading: auto-offset-for-heading,
    enable-pdfpc: enable-pdfpc,
    enable-mark-warning: enable-mark-warning,
    reset-page-counter-to-slide-counter: reset-page-counter-to-slide-counter,
    enable-frozen-states-and-counters: enable-frozen-states-and-counters,
    frozen-states: frozen-states,
    frozen-counters: frozen-counters,
    default-frozen-states: default-frozen-states,
    default-frozen-counters: default-frozen-counters,
    label-only-on-last-subslide: label-only-on-last-subslide,
    preamble: preamble,
    default-preamble: default-preamble,
    slide-preamble: slide-preamble,
    default-slide-preamble: default-slide-preamble,
    subslide-preamble: subslide-preamble,
    default-subslide-preamble: default-subslide-preamble,
    page-preamble: page-preamble,
    default-page-preamble: default-page-preamble,
    show-notes-on-second-screen: show-notes-on-second-screen,
    horizontal-line-to-pagebreak: horizontal-line-to-pagebreak,
    reset-footnote-number-per-slide: reset-footnote-number-per-slide,
    nontight-list-enum-and-terms: nontight-list-enum-and-terms,
    align-list-marker-with-baseline: align-list-marker-with-baseline,
    align-enum-marker-with-baseline: align-enum-marker-with-baseline,
    scale-list-items: scale-list-items,
    show-hide-set-list-marker-none: show-hide-set-list-marker-none,
    show-bibliography-as-footnote: show-bibliography-as-footnote,
  )) + args.named()
}


#let _default-init(self: none, body) = {
  body
}

#let _default-cover = utils.method-wrapper(hide)

#let _default-show-notes(self: none, width: 0pt, height: 0pt) = block(
  fill: rgb("#E6E6E6"),
  width: width,
  height: height,
  {
    set align(left + top)
    set text(size: 24pt, fill: black, weight: "regular")
    block(
      width: 100%,
      height: 88pt,
      inset: (left: 32pt, top: 16pt),
      outset: 0pt,
      fill: rgb("#CCCCCC"),
      {
        utils.display-current-heading(level: 1, depth: self.slide-level)
        linebreak()
        [ --- ]
        utils.display-current-heading(level: 2, depth: self.slide-level)
      },
    )
    pad(x: 48pt, utils.current-slide-note)
    // clear the slide note
    utils.slide-note-state.update(none)
  },
)

#let _default-alert = utils.method-wrapper(text.with(weight: "bold"))

#let _default-convert-label-to-short-heading(self: none, lbl) = utils.titlecase(
  lbl.replace(regex("^[^:]*:"), "").replace("_", " ").replace("-", " "),
)

/// The configuration of the methods.
///
/// - init (function): The function to initialize the presentation. It should be `(self: none, body) => { .. }`.
///
/// - cover (function): The function to cover content. The default value is `utils.method-wrapper(hide)` function.
///
///   You can configure it with `cover: utils.semi-transparent-cover` to use the semi-transparent cover.
///
/// - uncover (function): The function to uncover content. The default value is `utils.uncover` function.
///
/// - only (function): The function to show only the content. The default value is `utils.only` function.
/// 
/// - effect (function): The function to add effect to the content. The default value is `utils.effect`.
///
/// - alternatives-match (function): The function to match alternatives. The default value is `utils.alternatives-match` function.
///
/// - alternatives (function): The function to show alternatives. The default value is `utils.alternatives` function.
///
/// - alternatives-fn (function): The function to show alternatives with a function. The default value is `utils.alternatives-fn` function.
///
/// - alternatives-cases (function): The function to show alternatives with cases. The default value is `utils.alternatives-cases` function.
///
/// - alert (function): The function to alert the content. The default value is `utils.method-wrapper(text.with(weight: "bold"))` function.
///
/// - show-notes (function): The function to show notes on second screen. It should be `(self: none, width: 0pt, height: 0pt) => { .. }` with core code `utils.current-slide-note` and `utils.slide-note-state.update(none)`.
///
/// - convert-label-to-short-heading (function): The function to convert label to short heading. It is useful for the short heading for heading with label. It will be used in function with `short-heading`.
///
///   The default value is `utils.titlecase(lbl.replace(regex("^[^:]*:"), "").replace("_", " ").replace("-", " "))`.
///
///   It means that some headings with labels like `section:my-section` will be converted to `My Section`.
#let config-methods(
  // init
  init: _default,
  cover: _default,
  // dynamic control
  uncover: _default,
  only: _default,
  effect: _default,
  alternatives-match: _default,
  alternatives: _default,
  alternatives-fn: _default,
  alternatives-cases: _default,
  // alert interface
  alert: _default,
  // show notes
  show-notes: _default,
  // convert label to short heading
  convert-label-to-short-heading: _default,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    methods: _get-dict-without-default((
      init: init,
      cover: cover,
      uncover: uncover,
      only: only,
      effect: effect,
      alternatives-match: alternatives-match,
      alternatives: alternatives,
      alternatives-fn: alternatives-fn,
      alternatives-cases: alternatives-cases,
      alert: alert,
      show-notes: show-notes,
      convert-label-to-short-heading: convert-label-to-short-heading,
    )) + args.named(),
  )
}


/// The configuration of important information of the presentation.
///
/// Example:
///
/// ```typst
/// config-info(
///   title: "Title",
///   subtitle: "Subtitle",
///   author: "Author",
///   date: datetime.today(),
///   institution: "Institution",
/// )
/// ```
///
/// - title (content): The title of the presentation, which will be displayed in the title slide.
/// - short-title (content, auto): The short title of the presentation, which will be displayed in the footer of the slides usally.
///
///   If you set it to `auto`, it will be the same as the title.
///
/// - subtitle (content): The subtitle of the presentation.
///
/// - short-subtitle (content, auto): The short subtitle of the presentation, which will be displayed in the footer of the slides usally.
///
///   If you set it to `auto`, it will be the same as the subtitle.
///
/// - author (content): The author of the presentation.
///
/// - date (datetime, content): The date of the presentation.
///
///   You can use `datetime.today()` to get the current date.
///
/// - institution (content): The institution of the presentation.
///
/// - logo (content): The logo of the institution.
#let config-info(
  title: _default,
  short-title: _default,
  subtitle: _default,
  short-subtitle: _default,
  author: _default,
  date: _default,
  institution: _default,
  logo: _default,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    info: _get-dict-without-default((
      title: title,
      short-title: short-title,
      subtitle: subtitle,
      short-subtitle: short-subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: logo,
    )) + args.named(),
  )
}


/// The configuration of the colors used in the theme.
///
/// Example:
///
/// ```typst
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral: rgb("#303030"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// IMPORTANT: The colors should be defined in the *RGB* format at most cases.
///
/// There are four main colors in the theme: primary, secondary, tertiary, and neutral,
/// and each of them has a light, lighter, lightest, dark, darker, and darkest version.
#let config-colors(
  neutral: _default,
  neutral-light: _default,
  neutral-lighter: _default,
  neutral-lightest: _default,
  neutral-dark: _default,
  neutral-darker: _default,
  neutral-darkest: _default,
  primary: _default,
  primary-light: _default,
  primary-lighter: _default,
  primary-lightest: _default,
  primary-dark: _default,
  primary-darker: _default,
  primary-darkest: _default,
  secondary: _default,
  secondary-light: _default,
  secondary-lighter: _default,
  secondary-lightest: _default,
  secondary-dark: _default,
  secondary-darker: _default,
  secondary-darkest: _default,
  tertiary: _default,
  tertiary-light: _default,
  tertiary-lighter: _default,
  tertiary-lightest: _default,
  tertiary-dark: _default,
  tertiary-darker: _default,
  tertiary-darkest: _default,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    colors: _get-dict-without-default((
      neutral: neutral,
      neutral-light: neutral-light,
      neutral-lighter: neutral-lighter,
      neutral-lightest: neutral-lightest,
      neutral-dark: neutral-dark,
      neutral-darker: neutral-darker,
      neutral-darkest: neutral-darkest,
      primary: primary,
      primary-light: primary-light,
      primary-lighter: primary-lighter,
      primary-lightest: primary-lightest,
      primary-dark: primary-dark,
      primary-darker: primary-darker,
      primary-darkest: primary-darkest,
      secondary: secondary,
      secondary-light: secondary-light,
      secondary-lighter: secondary-lighter,
      secondary-lightest: secondary-lightest,
      secondary-dark: secondary-dark,
      secondary-darker: secondary-darker,
      secondary-darkest: secondary-darkest,
      tertiary: tertiary,
      tertiary-light: tertiary-light,
      tertiary-lighter: tertiary-lighter,
      tertiary-lightest: tertiary-lightest,
      tertiary-dark: tertiary-dark,
      tertiary-darker: tertiary-darker,
      tertiary-darkest: tertiary-darkest,
    )) + args.named(),
  )
}

/// The configuration of the page layout.
///
/// It is equivalent to the `#set page()` rule in Touying.
///
/// Example:
///
/// ```typst
/// config-page(
///   paper: "presentation-16-9",
///   header: none,
///   footer: none,
///   fill: rgb("#ffffff"),
///   margin: (x: 3em, y: 2.8em),
/// )
/// ```
///
/// - paper (string): A standard paper size to set width and height. The default value is "presentation-16-9".
///
///   You can also use `aspect-ratio` to set the aspect ratio of the paper.
///
/// - header (content): The page's header. Fills the top margin of each page.
///
/// - footer (content): The page's footer. Fills the bottom margin of each page.
///
/// - fill (color): The background color of the page. The default value is `rgb("#ffffff")`.
///
/// - margin (length, dictionary): The margin of the page. The default value is `(x: 3em, y: 2.8em)`.
///   - A single length: The same margin on all sides.
///   - A dictionary: With a dictionary, the margins can be set individually. The dictionary can contain the following keys in order of precedence:
///     - top: The top margin.
///     - right: The right margin.
///     - bottom: The bottom margin.
///     - left: The left margin.
///     - inside: The margin at the inner side of the page (where the binding is).
///     - outside: The margin at the outer side of the page (opposite to the binding).
///     - x: The horizontal margins.
///     - y: The vertical margins.
///     - rest: The margins on all sides except those for which the dictionary explicitly sets a size.
/// 
/// - numbering (string, function): The numbering style of the page. The default value is `"1"`.
///
///   The values for left and right are mutually exclusive with the values for inside and outside.
#let config-page(
  paper: _default,
  header: _default,
  footer: _default,
  fill: _default,
  margin: _default,
  numbering: _default,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    page: _get-dict-without-default((
      paper: paper,
      header: header,
      footer: footer,
      fill: fill,
      margin: margin,
      numbering: numbering,
    )) + args.named(),
  )
}


/// The default configurations
#let default-config = utils.merge-dicts(
  config-common(
    handout: false,
    slide-level: 2,
    slide-fn: slide,
    new-section-slide-fn: none,
    new-subsection-slide-fn: none,
    new-subsubsection-slide-fn: none,
    new-subsubsubsection-slide-fn: none,
    receive-body-for-new-section-slide-fn: true,
    receive-body-for-new-subsection-slide-fn: true,
    receive-body-for-new-subsubsection-slide-fn: true,
    receive-body-for-new-subsubsubsection-slide-fn: true,
    show-strong-with-alert: true,
    datetime-format: auto,
    appendix: false,
    freeze-slide-counter: false,
    zero-margin-header: true,
    zero-margin-footer: true,
    auto-offset-for-heading: false,
    enable-pdfpc: true,
    enable-mark-warning: true,
    reset-page-counter-to-slide-counter: true,
    // some black magics for better slides writing,
    // maybe will be deprecated in the future
    show-notes-on-second-screen: none,
    horizontal-line-to-pagebreak: true,
    reset-footnote-number-per-slide: true,
    nontight-list-enum-and-terms: false,
    align-list-marker-with-baseline: false,
    align-enum-marker-with-baseline: false,
    scale-list-items: none,
    show-hide-set-list-marker-none: true,
    show-bibliography-as-footnote: none,
    enable-frozen-states-and-counters: true,
    frozen-states: (),
    default-frozen-states: _default-frozen-states,
    frozen-counters: (),
    default-frozen-counters: _default-frozen-counters,
    label-only-on-last-subslide: (figure, math.equation, heading),
    preamble: none,
    default-preamble: _default-preamble,
    slide-preamble: none,
    default-slide-preamble: _default-slide-preamble,
    subslide-preamble: none,
    default-subslide-preamble: none,
    page-preamble: none,
    default-page-preamble: _default-page-preamble,
  ),
  config-methods(
    // init
    init: _default-init,
    cover: _default-cover,
    // dynamic control
    uncover: utils.uncover,
    only: utils.only,
    effect: utils.effect,
    alternatives-match: utils.alternatives-match,
    alternatives: utils.alternatives,
    alternatives-fn: utils.alternatives-fn,
    alternatives-cases: utils.alternatives-cases,
    // alert interface
    alert: _default-alert,
    // show notes
    show-notes: _default-show-notes,
    // convert label to short heading
    convert-label-to-short-heading: _default-convert-label-to-short-heading,
  ),
  config-info(
    title: none,
    short-title: auto,
    subtitle: none,
    short-subtitle: auto,
    author: none,
    date: none,
    institution: none,
    logo: none,
  ),
  config-colors(
    neutral: rgb("#303030"),
    neutral-light: rgb("#a0a0a0"),
    neutral-lighter: rgb("#d0d0d0"),
    neutral-lightest: rgb("#ffffff"),
    neutral-dark: rgb("#202020"),
    neutral-darker: rgb("#101010"),
    neutral-darkest: rgb("#000000"),
    primary: rgb("#303030"),
    primary-light: rgb("#a0a0a0"),
    primary-lighter: rgb("#d0d0d0"),
    primary-lightest: rgb("#ffffff"),
    primary-dark: rgb("#202020"),
    primary-darker: rgb("#101010"),
    primary-darkest: rgb("#000000"),
    secondary: rgb("#303030"),
    secondary-light: rgb("#a0a0a0"),
    secondary-lighter: rgb("#d0d0d0"),
    secondary-lightest: rgb("#ffffff"),
    secondary-dark: rgb("#202020"),
    secondary-darker: rgb("#101010"),
    secondary-darkest: rgb("#000000"),
    tertiary: rgb("#303030"),
    tertiary-light: rgb("#a0a0a0"),
    tertiary-lighter: rgb("#d0d0d0"),
    tertiary-lightest: rgb("#ffffff"),
    tertiary-dark: rgb("#202020"),
    tertiary-darker: rgb("#101010"),
    tertiary-darkest: rgb("#000000"),
  ),
  config-page(
    paper: "presentation-16-9",
    header: none,
    footer: none,
    margin: (x: 3em, y: 2.8em),
    numbering: "1",
  ),
  config-store(),
)