# Changelog

## v0.6.1

Added support for the [theorion](https://github.com/OrangeX4/typst-theorion) package, and used it as the default math theorem environment.

## v0.6.0

It's not a big update, but it's the first touying release since typst 0.13 was released.

### Features

- feat: add auto style for display-current-heading.
  - For users, you can use `show heading: set text(blue)` to change color for heading in some themes like `dewdrop`.
  - For theme creator, you can use syntax like `utils.display-current-heading(level: 1, style: auto)` to achieve the same result. 
- feat: apply config-info information to `set document`.
- feat: set `stretch: false` by default for `alternatives` functions. This is **a minor breaking change**, but I think it would be more intuitive: no auto empty space.

### Fixes

- fix: fix error with uncover using semi-transparent-cover
- fix: fix type string comparison https://github.com/touying-typ/touying/pull/153
- fix: fix horizontal-line bug in typst 0.13.0
- refactor: fix display-current-short-heading


## v0.5.4 & v0.5.5

### Features

- docs: improve param documentation and we have better hints for tinymist https://github.com/touying-typ/touying/pull/98
- feat: fake frozon states support for `heading` https://github.com/touying-typ/touying/pull/124
- feat: add alpha-changing-cover and color-changing-cover https://github.com/touying-typ/touying/pull/129
- feat: add effect function https://github.com/touying-typ/touying/issues/111
  - Example: `#effect(text.with(fill: red), "2-")[Something]` will display `[Something]` if the current slide is 2 or later.
- feat: add argument `config: (..)` for `xxx-slide` functions
- feat: add `align` argument for university theme

### Fixes

- fix: also hide enum numbers with show-hide-set-list-marker-none https://github.com/touying-typ/touying/pull/114
- fix: fixed progress bar not to break apart when global figure gutter is set nonzero https://github.com/touying-typ/touying/pull/120
- fix: fixed frozen-counters bug with multiple #pause commands https://github.com/touying-typ/touying/pull/124
- fix: fixed incorrect page num when draft is true https://github.com/touying-typ/touying/pull/125
- fix: fix behaviors of fit-to-height and fit-to-width partially https://github.com/touying-typ/touying/pull/131
- fix: duplicated footnotes in headings https://github.com/touying-typ/touying/pull/132
- fix: do not hardcode page sizes https://github.com/touying-typ/touying/pull/134
- fix: add default numbering for page https://github.com/touying-typ/touying/issues/100
- refactor: move show-strong-with-alert to per-slide level https://github.com/touying-typ/touying/issues/123
- refactor: remove unnecessary `config-page(fill: ...)`
- theme(metropolis): fix color of title page and fix https://github.com/touying-typ/touying/issues/103
- theme(metropolis): fixed metropolis slide's header to return content if title is specified https://github.com/touying-typ/touying/pull/126
- theme(metropolis): respect colors dict in metropolis theme https://github.com/touying-typ/touying/pull/133
- fix: fix bug of `#effect` function

Thanks for the contributions from [@enklht](https://github.com/enklht).


## v0.5.3

### Features

- feat: add `stretch` parameter for `#alternatives[]` function class. This allows us to handle cases where the internal element is a context expression.
- feat: add `config-common(align-enum-marker-with-baseline: true)` for aligning the enum marker with the baseline.
- feat: add `linebreaks` option to `components.mini-slides`. https://github.com/touying-typ/touying/pull/96
- feat: add `<touying:skip>` label to skip a new-section-slide.
- feat: add `config-common(show-hide-set-list-marker-none: true)` to make the markers of `list` and `enum` invisible after `#pause`.
- feat: add `config-common(bibliography-as-footnote: bibliography(title: none, "ref.bib"))` to display the bibliography in footnotes.
- refactor: add `config-common(show-strong-with-alert: true)` configuration to display strong text with an alert. (small breaking change for some themes)
- refactor: refactor `display-current-heading` for preserving heading style in title and subtitle. https://github.com/touying-typ/touying/issues/71
- refactor: make `new-section-slide-fn` function class can receive `body` parameter. We can use `receive-body-for-new-section-slide-fn` to control it. **(Breaking change)**
  - For example, you can add `#speaker-note[]` for a new section slide, like `= Section Title \ #speaker-note[]`.
  - If you don't want to append content to the body of the new section slide, you can use `---` after the section title.

### Fixes

- fix outdated documentation.
- fix bug of `enable-frozen-states-and-counters` in handout mode.
- fix unusable `square()` function. https://github.com/touying-typ/touying/issues/73
- fix hidden footer for `show-notes-on-second-screen: bottom`. https://github.com/touying-typ/touying/issues/89
- fix metadata element in table cells. https://github.com/touying-typ/touying/issues/77 https://github.com/touying-typ/touying/issues/95
- fix `auto-offset-for-heading` to `false` by default.
- fix uncover/only hides more content than it should. https://github.com/touying-typ/touying/issues/85
- theme(simple): fix wrong title and subtitle. https://github.com/touying-typ/touying/issues/70


## v0.5.1 & v0.5.2

- Fix somg bugs.


## v0.5.0

This is a significant disruptive version update. Touying has removed many mistakes that resulted from incorrect decisions. We have redesigned numerous features. The goal of this version is to make Touying more user-friendly, more flexible, and more powerful.

**Major changes include:**

- Avoiding closures and OOP syntax, which makes Touying's configuration simpler and allows for the use of document comments to provide more auto-completion information for the slide function.
  - The existing `#let slide(self: none, ..args) = { .. }` is now `#let slide(..args) = touying-slide-wrapper(self => { .. })`, where `self` is automatically injected.
  - We can use `config-xxx` syntax to configure Touying, for example, `#show: university-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`.
- The `touying-slide` function no longer includes parameters like `section`, `subsection`, and `title`. These will be automatically inserted into the slide as invisible level 1, 2, or 3 headings via `self.headings` (controlled by the `slide-level` configuration).
  - We can leverage the powerful headings provided by Typst to support numbering, outlines, and bookmarks.
  - Headings within the `#slide[= XXX]` function will be adjusted to level `slide-level + 1` using the `offset` parameter.
  - We can use labels on headings to control many aspects, such as supporting  the `<touying:hidden>` and other special labels, implementing short headings, or recalling a slide with `#touying-recall()`.
- Touying now supports the normal use of `set` and `show` rules at any position, without requiring them to be in specific locations.

A simple usage example is shown below, and more examples can be found in the `examples` directory:

```typst
#import "@preview/touying:0.5.0": *
#import themes.university: *

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.school,
  ),
)

#set heading(numbering: "1.1")

#title-slide()

= The Section

== Slide Title

#lorem(40)
```

**Theme Migration Guide:**

For detailed changes to specific themes, you can refer to the `themes` directory. Generally, if you want to migrate an existing theme, you should:

1. Rename the `register` function to `xxx-theme` and remove the `self` parameter.
2. Add a `show: touying-slides.with(..)` configuration.
   - Change `self.methods.colors` to `config-colors(primary: rgb("#xxxxxx"))`.
   - Change `self.page-args` to `config-page()`.
   - Change `self.methods.slide = slide` to `config-methods(slide: slide)`.
   - Change `self.methods.new-section-slide = new-section-slide` to `config-methods(new-section-slide: new-section-slide)`.
   - Change private theme variables like `self.xxx-footer` to `config-store(footer: [..])`, which you can access through `self.store.footer`.
   - Move the configuration of headers and footers into the `slide` function rather than in the `xxx-theme` function.
   - You can directly use `set` or `show` rules in `xxx-theme` or configure them through `config-methods(init: (self: none, body) => { .. })` to fully utilize the `self` parameter.
3. For `states.current-section-with-numbering`, you can use `utils.display-current-heading(level: 1)` instead.
   - If you only need the previous heading regardless of whether it is a section or a subsection, use `self => utils.display-current-heading(depth: self.slide-level)`.
4. The `alert` function can be replaced with `config-methods(alert: utils.alert-with-primary-color)`.
5. The `touying-outline()` function is no longer needed; you can use `components.adaptive-columns(outline())` instead. Consider using `components.progressive-outline()` or `components.custom-progressive-outline()`.
6. Replace `states.slide-counter.display() + " / " + states.last-slide-number` with `context utils.slide-counter.display() + " / " + utils.last-slide-number`. That is, we no longer use `states` but `utils`.
7. Remove the `slides` function; we no longer need this function. Instead of implicitly injecting `title-slide()`, explicitly use `#title-slide()`. If necessary, consider adding it in the `xxx-theme` function.
8. Change `#let slide(self: none, ..args) = { .. }` to `#let slide(..args) = touying-slide-wrapper(self => { .. })`, where `self` is automatically injected.
   - Change specific parameter configurations to `self = utils.merge-dicts(self, config-page(fill: self.colors.neutral-lightest))`.
   - Remove `self = utils.empty-page(self)` and use `config-common(freeze-slide-counter: true)` and `config-page(margin: 0em)` instead.
   - Change `(self.methods.touying-slide)()` to `touying-slide()`.
9. You can insert visible headings into slides by configuring `config-common(subslide-preamble: self => text(1.2em, weight: "bold", utils.display-current-heading(depth: self.slide-level)))`.
10. Finally, don't forget to add document comments to your functions so your users can get better auto-completion hints, especially when using the Tinymist plugin.

**Other Changes:**

- theme(stargazer): new stargazer theme modified from [Coekjan/touying-buaa](https://github.com/Coekjan/touying-buaa).
- feat: implemented fake frozen states support, allowing you to use numbering and `#pause` normally. This behavior can be controlled with `enable-frozen-states-and-counters`, `frozen-states`, and `frozen-counters` in `config-common()`.
- feat: implemented `label-only-on-last-subslide` functionality to prevent non-unique label warnings when working with `@equation` and `@figure` in conjunction with `#pause` animations.
- feat: added the `touying-recall(<label>)` function to replay a specific slide.
- feat: implemented `nontight-list-enum-and-terms`, which defaults to `true` and forces `list`, `enum`, and `terms` to have their `tight` parameter set to `false`. You can control spacing size with `#set list(spacing: 1em)`.
- feat: replaced `list` with `terms` implementation to achieve `align-list-marker-with-baseline`, which is off by default.
- feat: implemented `scale-list-items`, scaling list items by a factor, e.g., `scale-list-items: 0.8` scales list items by 0.8.
- feat: supported direct use of `#pause` and `#meanwhile` in math expressions, such as `$x + pause y$`.
- feat: provided `#pause` and `#meanwhile` support for most layout functions, such as `grid` and `table`.
- feat: added `#show: appendix` support, essentially equivalent to `#show: touying-set-config.with((appendix: true))`.
- feat: Introduced special labels `<touying:hidden>`, `<touying:unnumbered>`, `<touying:unoutlined>`, `<touying:unbookmarked>` to simplify control over heading behavior.
- feat: added basic `utils.short-heading` support to display short headings using labels, such as displaying `<sec:my-section>` as "My Section".
- feat: added `#components.adaptive-columns()` to achieve adaptive columns that span a page, typically used with the `outline()` function.
- feat: added `#show: magic.bibliography-as-footnote.with(bibliography("ref.bib"))` to display the bibliography in footnotes.
- feat: added components like `custom-progressive-outline`, `mini-slides`.
- feat: removed `touying-outline()`, which can be directly replaced with `outline()`.
- fix: replaced potentially incompatible code, such as `type(s) == "string"` and `locate(loc => { .. })`.
- fix: Fixed some bugs.


## v0.4.2

- theme(metropolis): decoupled text color with `neutral-dark` (Breaking change)
- feat: add mark-style uncover, only and alternatives
- feat: add warning for styled block for slides
- feat: add warning for touying-temporary-mark
- feat: add markup-text for speaker-note
- fix: fix bug of slides


## v0.4.1

### Features

- feat: support builtin outline and bookmark
- feat: support speaker note for dual-screen
- feat: add touying-mitex function

### Fixes

- fix: add outline-slide for dewdrop theme
- fix: fix regression of default value "auto" for repeat

### Miscellaneous Improvements

- feat: add list support for `touying-outline` function
- feat: add auto-reset-footnote
- feat: add `freeze-in-empty-page` for better page counter
- feat: add `..args` for register method to capture unused arguments


## v0.4.0

### Features

- **feat:** support `#footnote[]` for all themes.
- **feat:** access subslide and repeat in footer and header by `self => self.subslide`.
- **feat:** support numbered theorem environments by [ctheorems](https://typst.app/universe/package/ctheorems).
- **feat:** support numbering for sections and subsections.

### Fixes

- **fix:** make nested includes work correctly. 
- **fix:** disable multi-page slides from creating the same section multiple times.

## Breaking changes

- **refactor:** remove `self.padding` and add `self.full-header` `self.full-footer` config.


## v0.3.3

- **template:** move template to `touying-aqua` package, make Touying searchable in [Typst Universe Packages](https://typst.app/universe/search?kind=packages)
- **themes:** fix bugs in university and dewdrop theme
- **feat:** make set-show rule work without `setting` parameter
- **feat:** make `composer` parameter more simpler
- **feat:** add `empty-slide` function

## v0.3.2

- **fix critical bug:** fix `is-sequence` function, make `grid` and `table` work correctly in touying
- **theme:** add aqua theme, thanks for pride7
- **theme:** make university theme more configurable
- **refactor:** don't export variable `s` by default anymore, it will be extracted by `register` function (**Breaking Change**)
- **meta:** add `categories` and `template` config to `typst.toml` for Typst 0.11


## v0.3.1

- fix some typos
- fix slide-level bug
- fix bug of pdfpc label


## v0.3.0

### Features

- better show-slides mode.
- support align and pad.

### Documentation

- Add more detailed documentation.

### Refactor

- simplify theme.

### Fix

- fix many bugs.

## v0.2.1

### Features

- **Touying-reducer**: support cetz and fletcher animation
- **university theme**: add university theme

### Fix

- fix footer progress in metropolis theme
- fix some bugs in simple and dewdrop themes
- fix bug that outline does not display more than 4 sections


## v0.2.0

- **Object-oriented programming:** Singleton `s`, binding methods `utils.methods(s)` and `(self: obj, ..) => {..}` methods.
- **Page arguments management:** Instead of using `#set page(..)`, you should use `self.page-args` to retrieve or set page parameters, thereby avoiding unnecessary creation of new pages.
- **`#pause` for sequence content:** You can use #pause at the outermost level of a slide, including inline and list.
- **`#pause` for layout functions:** You can use the `composer` parameter to add yourself layout function like `utils.side-by-side`, and simply use multiple pos parameters like `#slide[..][..]`.
- **`#meanwhile` for synchronous display:** Provide a `#meanwhile` for resetting subslides counter.
- **`#pause` and `#meanwhile` for math equation:** Provide a `#touying-equation("x + y pause + z")` for math equation animations.
- **Slides:** Create simple slides using standard headings.
- **Callback-style `uncover`, `only` and `alternatives`:** Based on the concise syntax provided by Polylux, allow precise control of the timing for displaying content.
  - You should manually control the number of subslides using the `repeat` parameter.
- **Transparent cover:** Enable transparent cover using oop syntax like `#let s = (s.methods.enable-transparent-cover)(self: s)`.
- **Handout mode:** enable handout mode by `#let s = (s.methods.enable-handout-mode)(self: s)`.
- **Fit-to-width and fit-to-height:** Fit-to-width for title in header and fit-to-height for image.
  - `utils.fit-to-width(grow: true, shrink: true, width, body)`
  - `utils.fit-to-height(width: none, prescale-width: none, grow: true, shrink: true, height, body)`
- **Slides counter:** `states.slide-counter.display() + " / " + states.last-slide-number` and `states.touying-progress(ratio => ..)`.
- **Appendix:** Freeze the `last-slide-number` to prevent the slide number from increasing further.
- **Sections:** Touying's built-in section support can be used to display the current section title and show progress.
  - `section` and `subsection` parameter in `#slide` to register a new section or subsection.
  - `states.current-section-title` to get the current section.
  - `states.touying-outline` or `s.methods.touying-outline` to display a outline of sections.
  - `states.touying-final-sections(sections => ..)` for custom outline display.
  - `states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)` for powerful progress display.
- **Navigation bar**: Navigation bar like [here](https://github.com/zbowang/BeamerTheme) by `states.touying-progress-with-sections(..)`, in `dewdrop` theme.
- **Pdfpc:** pdfpc support and export `.pdfpc` file without external tool by `typst query` command simply.
