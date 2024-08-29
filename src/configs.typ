#import "states.typ"
#import "pdfpc.typ"
#import "utils.typ"
#import "core.typ": touying-slide-wrapper, touying-slide

/// The private configurations of the theme.
#let config-store(..args) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (store: args.named())
}

/// The common configurations of the slides.
///
/// - handout (bool): Whether to enable the handout mode. It retains only the last subslide of each slide in handout mode.
///
/// - cover (function): The function to cover content. The default value is `hide` function.
///
/// - slide-level (int): The level of the slides. The default value is `2`, which means the level 1 and 2 headings will be treated as slides.
///
/// - slide-fn (function): The function to create a new slide.
///
/// - new-section-slide (function): The function to create a new slide for a new section. The default value is `none`.
///
/// - new-subsection-slide (function): The function to create a new slide for a new subsection. The default value is `none`.
///
/// - new-subsubsection-slide (function): The function to create a new slide for a new subsubsection. The default value is `none`.
///
/// - new-subsubsubsection-slide (function): The function to create a new slide for a new subsubsubsection. The default value is `none`.
///
/// - datetime-format (string): The format of the datetime.
///
/// - appendix (bool): Is touying in the appendix mode. The last-slide-counter will be frozen in the appendix mode.
///
/// - freeze-slide-counter (bool): Whether to freeze the slide counter. The default value is `false`.
///
/// - zero-margin-header (bool): Whether to show the full header (with negative padding). The default value is `true`.
///
/// - zero-margin-footer (bool): Whether to show the full footer (with negative padding). The default value is `true`.
///
/// - auto-offset-for-heading (bool): Whether to add an offset relative to slide-level for headings.
///
/// - enable-pdfpc (bool): Whether to add `<pdfpc-file>` label for querying.
///
///   You can export the .pdfpc file directly using: `typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc`
///
/// ------------------------------------------------------------
/// The following configurations are some black magics for better slides writing,
/// maybe will be deprecated in the future.
/// ------------------------------------------------------------
///
/// - show-notes-on-second-screen (none, alignment): Whether to show the speaker notes on the second screen.
///
///   Currently, the alignment can be `none` and `right`.
///
/// - horizontal-line-to-pagebreak (bool): Whether to convert horizontal lines to page breaks.
///
///   You can use markdown-like syntax `---` to divide slides.
///
/// - reset-footnote-number-per-slide (bool): Whether to reset the footnote number per slide.
///
/// - nontight-list-enum-and-terms (bool): Whether to make `tight` argument always be `false` for list, enum, and terms. The default value is `true`.
///
/// - align-list-marker-with-baseline (bool): Whether to align the list marker with the baseline. The default value is `true`.
///
/// - scale-list-items (none, float): Whether to scale the list items recursively. The default value is `none`.
#let config-common(
  handout: false,
  slide-level: 2,
  slide-fn: (
    repeat: auto,
    setting: body => body,
    composer: auto,
    ..bodies,
  ) => touying-slide-wrapper(self => touying-slide(self: self, repeat: repeat, setting: setting, composer: composer, ..bodies)),
  new-section-slide-fn: none,
  new-subsection-slide-fn: none,
  new-subsubsection-slide-fn: none,
  new-subsubsubsection-slide-fn: none,
  datetime-format: auto,
  appendix: false,
  freeze-slide-counter: false,
  zero-margin-header: true,
  zero-margin-footer: true,
  auto-offset-for-heading: true,
  enable-pdfpc: true,
  enable-mark-warning: true,
  reset-page-counter-to-slide-counter: true,
  // some black magics for better slides writing,
  // maybe will be deprecated in the future
  enable-frozen-states-and-counters: true,
  frozen-states: (),
  default-frozen-states: (
    // ctheorems state
    state("thm",
      (
        "counters": ("heading": ()),
        "latest": ()
      )
    ),
  ),
  frozen-counters: (),
  default-frozen-counters: (counter(math.equation), counter(figure.where(kind: table)), counter(figure.where(kind: image))),
  first-slide-number: 1,
  preamble: none,
  default-preamble: self => {
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
  },
  slide-preamble: none,
  default-slide-preamble: none,
  subslide-preamble: none,
  default-subslide-preamble: none,
  page-preamble: none,
  default-page-preamble: self => {
    if self.at("reset-footnote-number-per-slide", default: true) {
      counter(footnote).update(0)
    }
    if self.at("reset-page-counter-to-slide-counter", default: true) {
      context counter(page).update(states.slide-counter.get())
    }
    if self.at("enable-pdfpc", default: true) {
      context [
        #metadata((t: "NewSlide")) <pdfpc>
        #metadata((t: "Idx", v: here().page() - 1)) <pdfpc>
        #metadata((t: "Overlay", v: self.subslide - 1)) <pdfpc>
        #metadata((t: "LogicalSlide", v: states.slide-counter.get().first())) <pdfpc>
      ]
    }
  },
  show-notes-on-second-screen: none,
  horizontal-line-to-pagebreak: true,
  reset-footnote-number-per-slide: true,
  nontight-list-enum-and-terms: true,
  align-list-marker-with-baseline: true,
  scale-list-items: none,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    handout: handout,
    slide-level: slide-level,
    slide-fn: slide-fn,
    new-section-slide-fn: new-section-slide-fn,
    new-subsection-slide-fn: new-subsection-slide-fn,
    new-subsubsection-slide-fn: new-subsubsection-slide-fn,
    new-subsubsubsection-slide-fn: new-subsubsubsection-slide-fn,
    datetime-format: datetime-format,
    appendix: appendix,
    freeze-slide-counter: freeze-slide-counter,
    zero-margin-header: zero-margin-header,
    zero-margin-footer: zero-margin-footer,
    auto-offset-for-heading: auto-offset-for-heading,
    enable-pdfpc: enable-pdfpc,
    enable-mark-warning: enable-mark-warning,
    frozen-states: frozen-states,
    frozen-counters: frozen-counters,
    default-frozen-states: default-frozen-states,
    default-frozen-counters: default-frozen-counters,
    first-slide-number: first-slide-number,
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
    scale-list-items: scale-list-items,
  ) + args.named()
}


/// The configuration of the methods
#let config-methods(
  cover: utils.wrap-method(hide),
  // dynamic control
  uncover: utils.uncover,
  only: utils.only,
  alternatives-match: utils.alternatives-match,
  alternatives: utils.alternatives,
  alternatives-fn: utils.alternatives-fn,
  alternatives-cases: utils.alternatives-cases,
  // alert interface
  alert: utils.wrap-method(text.with(weight: "bold")),
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    methods: (
      cover: cover,
      uncover: uncover,
      only: only,
      alternatives-match: alternatives-match,
      alternatives: alternatives,
      alternatives-fn: alternatives-fn,
      alternatives-cases: alternatives-cases,
      alert: alert,
    ) + args.named(),
  )
}


/// The configuration of important information of the presentation.
///
/// #example(```
/// config-info(
///   title: "Title",
///   subtitle: "Subtitle",
///   author: "Author",
///   date: datetime.today(),
///   institution: "Institution",
/// )
/// ```)
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
  title: none,
  short-title: auto,
  subtitle: none,
  short-subtitle: auto,
  author: none,
  date: none,
  institution: none,
  logo: none,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  if short-title == auto {
    short-title = title
  }
  if short-subtitle == auto {
    short-subtitle = subtitle
  }
  return (
    info: (
      title: title,
      short-title: short-title,
      subtitle: subtitle,
      short-subtitle: short-subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: logo,
    ) + args.named(),
  )
}


/// The configuration of the colors used in the theme.
///
/// #example(```
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral: rgb("#303030"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```)
///
/// IMPORTANT: The colors should be defined in the *RGB* format at most cases.
///
/// There are four main colors in the theme: primary, secondary, tertiary, and neutral,
/// and each of them has a light, lighter, lightest, dark, darker, and darkest version.
#let config-colors(
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
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    colors: (
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
    ) + args.named(),
  )
}

/// The configuration of the page layout.
///
/// It is equivalent to the `#set page()` rule in Touying.
///
/// #example(```
/// config-page(
///   paper: "presentation-16-9",
///   header: none,
///   footer: none,
///   fill: rgb("#ffffff"),
///   margin: (x: 3em, y: 2.8em),
/// )
/// ```)
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
///   The values for left and right are mutually exclusive with the values for inside and outside.
#let config-page(
  paper: "presentation-16-9",
  header: none,
  footer: none,
  fill: rgb("#ffffff"),
  margin: (x: 3em, y: 2.8em),
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    page: (
      paper: paper,
      header: header,
      footer: footer,
      fill: fill,
      margin: margin,
    ) + args.named(),
  )
}


/// The default configurations
#let default-config = utils.merge-dicts(
  config-common(),
  config-methods(),
  config-info(),
  config-colors(),
  config-page(),
)