# Changelog

## v0.8.0 (unreleased)

A big release, and the first that requires **Typst 0.15**.

The main new feature is **article mode**: the same source file compiles either to slides or to a flowing prose document, with animations collapsed to their final state and images optionally floated to the side. Two new animation entry points come with it. `touying-render` renders a piece of content at chosen animation stages, and `animate` combines visibility and styling on one piece of content. `touying-recall` was extended from whole slides to any labelled element. `touying-fn-wrapper-raw` now parses and nests its body, so `#alert[.. #pause ..]` works, and much more besides. `.pdfpc` files can be written directly as bundle assets instead of through a separate `typst query` step. The footnote bibliography was rebuilt on real Typst bibliographies, and the speaker-note panel is now a theme-supplied function with documentation to match. Internally, `src/core.typ` (6288 lines) was split into modules.

Things to watch when upgrading: a `#pause` after `uncover`/`only`/`alternatives` no longer skips the subslides they reserve, the footnote-bibliography config changed shape, `semi-transparent-cover` is deprecated, and on a second screen the page background is confined to the slide half. There is a migration guide below, and a separate one for theme authors at the end. Most documentation pages were rewritten or corrected.

### Breaking Changes

- **feat!: Touying now requires Typst 0.15.0**

  `typst.toml`'s `compiler` field goes from `0.12.0` to `0.15.0`. Bundle export for `.pdfpc` assets and the reworked cover methods both need it. All reference renders were regenerated against Typst 0.15 / tytanic 0.4.

- **fix!: a `#pause` after `uncover`/`only`/`alternatives` no longer skips the subslides they reserve**

  ```typst
  #uncover("2")[Only on subslide 2]
  On subslide one
  #pause
  On subslide two    // v0.7.0-v0.7.4: on subslide *three*
  ```

  Up to v0.6.x a relative jump advanced the counter by one. v0.7.0 changed it to snap past the highest subslide any preceding fn-wrapper had reserved. That was meant for `item-by-item`, which stands in for a run of pauses and should push a later `#pause` past its whole animation. But `item-by-item` reports its extent through the same channel as every other wrapper, so the change caught `uncover`, `only` and `alternatives` as well. No test asserted it and it slipped past. Reserving subslides and consuming them are separate things again.

  Waypoint placement gets the same correction. `#waypoint(<w>)` after an `#uncover("5")` now lands one past the current flow position, not one past subslide 5.

  **Migration:** if you relied on the snap, add the extra `#pause` (or `#jump(n, relative: true)` or waypoints) yourself. `item-by-item` and `item-by-item-fn` are unaffected. They still push later pauses past their last item, and they now match the hand-written `#pause` sequence they abbreviate, including for content that follows them without any `#pause`.

- **feat!: `show-bibliography-as-footnote` is a boolean, and `magic.bibliography()` is gone**

  The old mechanism took the bibliography element itself, as `config-common(show-bibliography-as-footnote: bibliography("ref.bib"))`, hid it in the preamble, collected the entries into a state, and re-rendered them through `magic.bibliography()`. That state is gone. Set the flag and call a real `#bibliography(..)` in the presentation:

  ```typst
  #show: simple-theme.with(
    config-common(show-bibliography-as-footnote: true),
  )

  == References
  #bibliography("ref.bib")
  ```

  The bibliography has to be part of the document for the footnote citations to resolve. Use `hide(bibliography(..))` if you do not want the reference list shown. Multiple bibliographies work now, and [#395](https://github.com/touying-typ/touying/issues/395), where a footnote bibliography that overflowed its slide stopped the document converging, is fixed as a result. If your citation style already produces notes, such as `"chicago-notes"`, leave the flag at `false`. See the [FAQ](https://touying-typ.github.io/docs/faq).

  `magic.bibliography-as-footnote` loses its `bibliography` parameter and gains `footnote-style`, a dictionary of `super` properties for the citation markers. The default `(typographic: false, baseline: 0em, size: 1em)` makes them read as normal text.

- **feat!: the speaker-note panel is customizable through `config-common(notes-fn: ..)`; the `config-methods(show-only-notes: ..)` *renderer* is removed** ([#353](https://github.com/touying-typ/touying/issues/353))

  `show-only-notes` was two separate options in v0.7.4 and only one of them changes. `config-common(show-only-notes: true)`, the flag that turns on presenter view, works as before, and is documented for the first time in [Speaker Notes](https://touying-typ.github.io/docs/tutorials/speaker-notes). What is gone is `config-methods(show-only-notes: ..)`, the function that drew the panel. Only theme authors ever overrode it.

  The panel is now produced by a theme-supplied function, the way slides are produced by `slide-fn`. `notes-fn(self: none, note: none, slide-preview: none) -> content` mirrors `slide-fn`, and `touying-notes` is the counterpart of `touying-slide`: it owns the rough layout, the theme passes colours and arranges the content. All six bundled themes register their own, so the notes panel matches the deck in spirit. Some alignment bugs will be fixed later.

  `show-only-notes` mode was restructured along with it. The slide's parts, previously shown on the top right, are reassembled into one page-sized box and handed to the theme as `slide-preview` content to place where and scale how it likes. The old `cutout` / `cutout-height` / `(background, foreground)` return protocol is gone, and `slide-preview: none` tells a theme it is on a second screen. This also fixes [#281](https://github.com/touying-typ/touying/issues/281): the panel background was placed from the page header and nearly all of it fell off-page, so the declared `#CCCCCC`/`#E6E6E6` colours never rendered.

  See [Customizing the Speaker-Note Panel](https://touying-typ.github.io/docs/themes/custom) and [Build Your Own Theme](https://touying-typ.github.io/docs/tutorials/build-your-own-theme).

- **fix!: the page background and foreground are confined to the slide half on a second screen** ([#219](https://github.com/touying-typ/touying/issues/219))

  With `show-notes-on-second-screen`, Touying doubles the page along one axis and pushes the extra half into the margin (Now all four alignments are supported). `page(background: ..)` covers the whole page, so a background sized `100%`, or an image with `fit: "cover"`, was stretched across the slide and the notes half together. `background` and `foreground` are now each placed in a box the size of one slide, on the slide's own half, so percentage sizes and `fit: "cover"` behave as they do without a second screen.

- **feat!: `touying-recall`'s `subslide:` parameter becomes `subslides:`, and its `none`/`auto` values swap**

  The parameter is now plural because it takes ranges (since v0.6.3) rather than a single subslide, matching `visible-subslides` on `uncover`/`only`/`effect`. It accepts a superset of the old values.

  `subslides: auto` is the new default. It recalls all subslides of a whole-slide target, or the final animation state of a labelled element. `subslides: none` recalls only the last subslide. v0.7.4 had these the other way round, with `none` as the default, so the default behaviour is unchanged. Only code that passed either value explicitly needs the value swapped as well as the key renamed.

### Minor Breaking Changes

- **feat!: `utils.semi-transparent-cover` is deprecated** — use `utils.alpha-changing-cover` or `utils.color-changing-cover`

  It worked by overlaying a semi-transparent rectangle on the covered content, which does not hold up in general: the overlay dims the slide background along with the content, and it stacks where covered regions overlap. It still renders, (slightly worse than the last iterations) so presentations keep compiling. Builds that use `--warnings promote` will however fail.

  ```typst
  // Before
  config-methods(cover: utils.semi-transparent-cover)
  // After: a real alpha cover, with an automatic fallback for content it cannot recolour
  config-methods(cover: utils.alpha-changing-cover)
  // Or, cheaper to compile, flattening everything to one colour
  config-methods(cover: utils.color-changing-cover.with(color: gray))
  ```

  Passing it as another cover method's `fallback-hide` function is still fine and does not warn. `utils.cover-with-rect` does also not warn.

- **fix!: `utils.handout-only` is removed** — use the top-level `#handout-only[..]`. It is a parser mark rather than a callback, so it can contain slide-breaking content. See [Handout Mode](https://touying-typ.github.io/docs/tutorials/dynamic/handout).

### Migration Guide

1. **Bump your compiler** to Typst 0.15.0 or newer.
2. **Bibliography:** replace `config-common(show-bibliography-as-footnote: bibliography("ref.bib"))` with `config-common(show-bibliography-as-footnote: true)` and put a real `#bibliography("ref.bib")` in the presentation. Delete any `#magic.bibliography(..)` call. If the bibliography sits on a slide with more than one subslide, wrap it as `only("h", bibliography("ref.bib"))` so it is instantiated once. Otherwise each subslide creates a fresh instance and the citation numbering restarts ([#415](https://github.com/touying-typ/touying/issues/415)).
3. **Speaker notes:** if you overrode the `config-methods(show-only-notes: ..)` *renderer*, rewrite it as `config-common(notes-fn: ..)` built on top of `touying-notes`. `config-common(show-only-notes: true)` needs no change.
4. **Second screen:** if a theme painted behind the notes half through `config-page(background: ..)`, move that styling into its `notes-fn` (`fill` / `header-fill` on `touying-notes`).
5. **`touying-recall`:** rename `subslide:` to `subslides:`. If you passed `none` or `auto` explicitly, swap it for the other one. If you relied on the default, nothing changes.
6. **Covers:** replace `config-methods(cover: utils.semi-transparent-cover)` with `utils.alpha-changing-cover` or `utils.color-changing-cover`. Leaving it is a warning rather than an error, unless you build with `--warnings promote`.
7. **Pause flow:** see the first breaking entry. Add an explicit `#pause` or `#jump`, or use waypoints, where you relied on a fn-wrapper snapping the counter forward.

### Features

- **feat: article mode, one source file for slides or a flowing article**

  Compiling with `config-common(export-mode: "article")`, or with `typst compile slides.typ --input export-mode=article`, renders the whole deck as a continuous document instead of pages: no slide breaks, animations collapsed to their final state, images optionally floated to the side. `export-mode` accepts `"slides"` (the default, where the `handout` flag decides), `"presentation"`, `"handout"` and `"article"`. `config-common(article-mode: true)` is the raw switch behind it.

  ```typst
  #show: simple-theme.with(
    config-common(
      export-mode: "article",
      article-theme: themes.article.article-theme.with(numbering: "1.1"),
    ),
    config-article(
      wrap-images: true,
      available-fields: (title: "info.title"),
    ),
  )
  ```

  Two markers let you write for the article target. `#article-text[..]` placed after a slide replaces that slide's content in the article, so you can give a prose paragraph instead of bullet points. `#article-only[..]` adds content that appears only in the article (for more see mode-only content below). The new `config-article(..)` group covers article-side layout: `wrap-images`, `wrap-image-figures`, `wrap-other-figures`, `wrap-other` and `wrap-align-direction` for side-floating (done with `meander`), plus an optional `title-block-fn`, and `available-fields`: a mapping that hands configuration values such as `info.title` through to the article theme's own parameters.

- **feat: `themes.article`, a plain A4 article theme**

  The default target of `article-theme: auto`. It does not depend on the presentation framework, so it also works standalone for papers and reports. It is meant as an example; any article-like theme can be used instead.

- **feat: mode-only content and mode labels**

  Four inline markers select content by output target: `#article-only[..]`, `#handout-only[..]`, `#presentation-only[..]` and `#slides-only[..]`, the last meaning both slide modes but not the article. Hidden content is removed entirely and reserves no space, and the body can contain slide-breaking elements, so a heading inside `#handout-only[..]` really does start a new slide in handout mode.

  The same choice exists per slide as heading and slide labels: `<touying:presentation>`, `<touying:handout>`, `<touying:slides>` and `<touying:article>`, combinable with hyphens, where `<touying:presentation-article>` means "or". The new `<touying:never>` is the Typst equivalent of `\iffalse`. It parks a slide out of every render without you having to comment out markup. See [Handout Mode](https://touying-typ.github.io/docs/tutorials/dynamic/handout) and [Sections and Headings](https://touying-typ.github.io/docs/tutorials/sections).

- **feat: `touying-recall` recalls any labelled element, not just whole slides**

  Besides a whole slide, `#touying-recall(<lbl>)` now takes a labelled reducer, a labelled diagram, or any labelled animated content as well, and replays it at a chosen stage:

  ```typst
  #touying-recall(<my-slide>, subslides: "waypoints")  // one subslide per waypoint
  #touying-recall(<my-diagram>, subslides: 1)          // a reducer at stage 1
  #touying-recall(<my-table>)                          // plain labelled content
  ```

  Subslide selection accepts ints, including negative indices counted back from the last subslide, waypoint labels, and waypoint markers (`get-first`, `get-last`, `prev-wp`, `next-wp`), resolved against the recalled content's own waypoints. Recalling an element places it inline; only recalling a whole slide starts a new page. And a recall can sit inside `#only`/`#uncover`/`#alternatives` anywhere in their body, not just as the whole body, and `base:` sets the starting repetition counter for content with its own numbered steps.

- **feat: `touying-render` renders content at a chosen animation stage, or steps through a range**

  Where `touying-recall` looks up previous content by label, `touying-render` takes the content value directly. It is useful for miniature previews or for showing a diagram's intermediate state in the article output and probably much more. You can even render entire slide contents with it.

  ```typst
  #touying-render(body, subslides: "2-4")   // steps through 2, 3 and 4
  #touying-render(body, subslides: "!2-3")  // skips 2-3, collapsing the gap
  #touying-render(body, subslides: <wp>)    // the waypoint's whole range
  ```

  A single-point spec, such as a plain int, `get-first` or `get-last`, freezes one stage. `subslides: auto` follows the enclosing slide's own progression. `base:` offsets the content's internal pause numbering, `start:` sets where in the enclosing slide the first subslide rendered begins, and `repeat-last:` controls whether the content holds at its final stage (the default) or disappears again.

- **feat: `animate`, for combining visibility and styling on one piece of content**

  ```typst
  #animate(
    [The original],
    effects: (
      (effect: "cover", subslides: "-2"),
      (effect: swap[Something else], subslides: 3),
      (effect: (body, ..) => text(red, body), subslides: "4-", priority: 2),
    ),
  )
  ```

  Placements (`"show"`, `"cover"`, `"remove"`, `swap(..)`) resolve to a single winner per subslide. They cannot be composed: the only cover method is `hide`, which is not a style node, and `"remove"` drops the content outright, so neither can be undone from inside. If you need alpha-changed covered content use styling effect functions instead. Styling functions do compose and nest. Priority picks the winning placement and orders the nesting, and ties break consistently in both classes: the last effect you wrote wins. For a placement that means it is the one used; for a style it means it ends up innermost, so it wins any property both of them set. `swap` takes `stretch`, like `alternatives` does: without it the layout reflows while the swap is shown, with it the swap joins the reserved space and the block keeps one size. Measuring only happens if some swap sets `stretch`, and each distinct combination of placement and styles is measured once. `animate-hidden` and `animate-removed` are the same function starting from `"cover"` and `"remove"`, respectively, instead of `"show"`, so effects by default say when the `body` appears rather than when it disappears. You can of course override this in any case, these are just shorthands.

- **feat: `advances-flow` on `touying-fn-wrapper`, for wrappers that stand in for a run of pauses**

  The flag that keeps `item-by-item` pushing later pauses past its last item is an ordinary parameter, so your own wrappers can opt in:

  ```typst
  #let reveal-lines(body) = touying-fn-wrapper(
    (self: none, body) => /* ... */ body,
    last-subslide: repetitions => (repetitions + count-lines(body) - 1, (:)),
    advances-flow: true,   // a following #pause continues after the last line
    body,
  )
  ```

  It defaults to `false`, which is what you want for anything that only animates its own body. Such a wrapper reserves the subslides it needs without moving the pause cursor.

- **feat: `touying-fn-wrapper-raw` parses its body nests recursively, while `touying-fn-wrapper` allows raw variants inside itself**

  `#alert[This is important, #only("2-")[easter egg] don't miss it!]` used to panic with *Unsupported mark*. A raw wrapper handed its positional arguments straight to the wrapped function, so any animation marker inside survived as unresolved metadata. Those arguments now go through the parser like ordinary slide content, so `#pause`, `#meanwhile` and every fn-wrapper behave inside a raw wrapper as they do anywhere else, and the wrapper's content counts towards the slide's subslide total. Nested raw wrappers resolve recursively, so `#uncover[#alert[a #alert[b #alert[c]]]]` works all the way down.

  This makes `touying-fn-wrapper-raw` the better default for reaching `self` from markup, and the docs and themes now say so. Stargazer's `tblock` was switched over so it can be used with the normal animation functions. The body has to be a positional argument for any of this to apply; baking it in with `.with(..)` hides it from the parser. See [Complex Animations](https://touying-typ.github.io/docs/tutorials/dynamic/complex).

- **feat: export `.pdfpc` files as bundle assets, one per document** ([#408](https://github.com/touying-typ/touying/issues/408))

  Typst 0.15's bundle export can emit arbitrary files, so the separate `typst query .. > example.pdfpc` step is no longer needed (you can still use it and the docs have transitioned to `typst eval` now). Put `#pdfpc.bundle-assets()` at the top level, outside every `#document(..)`:

  ```sh
  typst compile --features bundle --format bundle --root . ./example.typ ./out
  # => ./out/deck.pdf and ./out/deck.pdfpc
  ```

  Every PDF document in the bundle that carries pdfpc metadata gets its own `.pdfpc` next to it, with slide labels numbered from that document's own first slide and only that document's notes, markers and configuration in it. The call is inert in every other target, so it can stay in a file you also compile to a plain PDF. See [pdfpc](https://touying-typ.github.io/docs/external/pdfpc).

- **feat: several documents in one source file** ([#406](https://github.com/touying-typ/touying/issues/406), thanks @mxmerz)

  Typst 0.15's bundle export lets a single file emit more than one PDF through `#document("name.pdf", [..])`, and a deck can now live in each of them. Heading lookups are scoped to the document they are in, so `utils.current-heading` and everything built on it (slide headers, the notes panel, progressive outlines) no longer pick up headings from a neighbouring deck. pdfpc metadata is scoped the same way, see the bundle-asset entry above.

  ```typst
  #document("deck-a.pdf", [
    #show: simple-theme
    == Deck A
  ])
  #document("deck-b.pdf", [
    #show: simple-theme
    == Deck B
  ])
  ```

- **feat: themes style the speaker-note panel through `touying-notes`**

  `touying-notes` takes `header`, `header-fill`, `fill`, `note-setting` and `preview-setting`; a theme may use the `note-setting` to style the page and content. `header-height` collapses to its content by default, and `header: none` drops the strip entirely. `preview-setting` receives the full-size slide preview, so a theme can scale and place it freely, for example `preview => place(bottom + right, box(scale(x: 30%, y: 15%, reflow: true, preview)))`. All six bundled themes ship one. See [Speaker Notes](https://touying-typ.github.io/docs/tutorials/speaker-notes).

- **feat: `show-notes-on-second-screen` accepts `top` and `left`** as well as `bottom` and `right`. The page is doubled along the corresponding axis and the extra half pushed into the margin, so the slide keeps its own dimensions in all four directions.

- **feat: better covering, with `alpha-changing-cover` and `color-changing-cover` reworked** ([#112](https://github.com/touying-typ/touying/issues/112))

  `utils.alpha-changing-cover` is now the recommended semi-transparent cover, replacing the deprecated `semi-transparent-cover` above. It governs every stylable colour, inherits the outer scope's colour when an element declares none, understands gradients and tilings, and converts spot colours to Oklch before opacifying. Its automatic fallback alpha depends on the lightness of the colour it is dimming, and the fallback path is used far more sparingly, so images and diagrams no longer turn into grey blocks. `utils.color-changing-cover` remains the compile-cheap alternative that flattens everything to one colour. See [Cover Function](https://touying-typ.github.io/docs/tutorials/dynamic/cover).

- **feat: `components.left-mid-right` places content in three columns** ([#397](https://github.com/touying-typ/touying/pull/397), thanks @thomas-saigre)

- **feat: `utils.get-input` for reading command-line inputs**

  Everything passed through `--input key=value` reaches Typst as a string. `utils.get-input` parses each value as Typst first, so `accent=red` is a colour, `count=3` an integer and `flag=true` a boolean, while a bare word Typst does not know comes back as a string. That last part is what makes `--input export-mode=handout` work without shell quoting. Rn we only depend on it for export-mode, but we might support more commandline customizability later. Pass no key to get the whole parsed dictionary. See [touying-exporter](https://touying-typ.github.io/docs/external/touying-exporter).

- **feat/fix: `touying-get-config` exposes `common` as a real category**

  `touying-get-config("common.handout")` resolves now, and `touying-get-config().common` returns the flat top-level keys as a subtree, which is what the docstring always claimed. Naming a category under it, such as `common.store`, panics with a clear message instead of silently missing.

- feat: new utilities. `utils.is-math-symbol`, `utils.sequence-to-array`, `utils.resolve-negative-subslides` (negative subslide indices resolved against a repeat count and an optional non-1 base), and `utils.rescale-image` (used by article mode's image wrapping).

- **feat: mode markers and `#article-text` work inside a slide body**

  A `#slide[..]` call injects config, a composer or slide-level layout, and content is meant to mean the same thing with or without one. `#slide[#slides-only[..]]` did not: a slide captures its body and renders it past the walk that resolves those marks, so it reached layout unconsumed and panicked. Which half of a slide a marker covers is now the author's choice, `#slide[a #slides-only[b] c]` keeping `b` out of the article and `#slides-only(slide[a b c])` keeping the whole slide out. `#article-text[..]` inside a slide stands in for that slide, matching what it does at document level.

- **feat: `config-article(wrap-width: ..)` sets how much of the page a float takes**

  Article mode linearizes a deck rather than carrying its layout over, so the composer no longer decides how a float looks. A floated element takes 50% of the text width by default, whatever width it was written at for the slide, and an image is scaled to fill it.

- **feat: `color-changing-cover` gained `hide-filled`**

  An element that paints its own background would be flattened together with the content on top of it, so those go to `fallback-hide` instead of being recoloured. That was previously a hard-coded list of element functions; it is a parameter now, and `fallback-hide` defaults to `auto`, dimming them to match the recoloured text.

### Fixes

- **fix: covering no longer errors on `align`, `place`, `columns`, `link` or `rotate`**

  The tree-rebuilding cover methods put every field of an element back as a named argument, which those five reject because their defining field is positional, so `#uncover("2-")[#align(center)[..]]` failed with `unexpected argument: alignment`. The same gap hit `polygon`, `curve`, `math.class` and the `underbrace` family. `scale` is why it stayed hidden: since Typst 0.15 it has no `factor` field, only the resolved named `x`/`y`, so the one transform everybody reaches for happened to work. Matters because v0.8.0 promotes `alpha-changing-cover` as the replacement for the deprecated `semi-transparent-cover`.

- **fix: a labelled `#place`, `#rotate`, `#columns` or `#terms.item` in a slide**

  The parser rebuilt those four by hand and passed the label straight into the constructor, so a labelled `#place(top + right)[..] <lbl>` was a hard compile error and a labelled `#columns(2)[..] <lbl>` silently lost its label. They go through the shared reconstruction now and keep it.

- **fix: covering no longer moves content**

  A text run with no colour of its own was rebuilt into a fresh `text(..)` node, which split it out of the run it was shaped in. An inline `#quote[..]` moved by 0.6pt when covered and does not now. Non-text content is also no longer given a 1pt outset, which showed as a grey outline around the very element being covered.

- **fix: the two cover methods agree**

  `color-changing-cover` ignored a configured `fallback-hide` for images, never touched strokes on `box`, `block`, `table` or `grid`, destroyed `table.cell`, and never entered the bodies of `underline`, `highlight` and `strike`; `alpha-changing-cover` did not cover `cite` or `ref`. Both walk one tree now, so these behave the same way.

- **fix: `#item-by-item` no longer collapses when its body starts with a `#set`**

  Three separate copies of "count the items" could not see through the `styled` node a `#set` or `#show` creates, so `#item-by-item[#set text(..) \ - one \ - two]` rendered one subslide instead of three.

- **fix: `magic.nontight` on a labelled list**

  It splatted the element's `label` into the constructor, which rejects it, so `#list([a], [b]) <lbl>` was a hard error under `nontight-list-enum-and-terms`.

- **fix: speaker notes no longer lose styled content**

  `utils.markup-text` dropped every `styled` subtree, so `[a #text(red)[b] c]` reached the `.pdfpc` file as "a c". It feeds the pdfpc export, so notes were silently incomplete.

- **fix: a top-level `#set` or `#show` no longer breaks article mode**

  Such a rule wraps the entire rest of the document in one `styled` node. Article mode did not look inside it, so headings stopped bounding sections, mode labels stopped filtering, and every `#article-text` / `#article-only` / `#slide[..]` mark in the document went unconsumed and ended the compile with `Unsupported mark`. A `#touying-recall` of a reducer failed the same way, with `refers to content with no subslide dimension`.

- **fix: user blocks survive article mode**

  Article mode strips the `block()` wrappers it generates itself, and was taking any block the author wrote with them, along with its fill, stroke, inset and label. This was the default configuration.

- **fix: `#article-text` replaces the floats of the content it stands in for**

  A `#components.side-by-side[..][..]` in front of an `#article-text[..]` still turned up in the article beside the prose meant to replace it.

- **fix: waypoints inside a `terms.item` or a figure caption**

  The waypoint pre-pass walked neither, while the main parse walked both, so every waypoint after one landed on the wrong subslide.

- **fix: special slides announce their title as a hidden heading**

  An outline slide's title never became a heading, so nothing reading the current heading could see it. The slide header worked only because the title was passed in explicitly, and the notes panel showed nothing at all. The affected slides now emit `place(hide(heading(level: self.slide-level, ..)))`. `place` keeps it out of the flow, since a plain `hide` still pushed the outline's contents down by about 16pt, and `level: self.slide-level` keeps `custom-progressive-outline` from mistaking "Outline" for the current section and dimming every entry. Applied to `outline-slide` in aqua, dewdrop, metropolis and stargazer, plus stargazer's `ending-slide`. Title slides are left alone for now.

- **fix: a citation covered by a visual-only method stays a real citation**

  `color-changing-cover` sent citations to the `hide` fallback, so the marker vanished while the bibliography entry it queues stayed behind. `@key` is a `ref` in the content tree and only becomes a `cite` during layout, so neither func was in the recolourable set. Both are now, and a citation is recoloured like `raw` rather than hidden. Separately, `magic.bibliography-as-footnote` decided whether to draw a width-reserving placeholder by looking for a `hide` element instead of asking `utils.cover-hides-footnote`. It asks the config now, so it agrees with the parser's own footnote branch.

  Still open: an opaque cover that is not `hide`, such as `cover-with-rect`, together with `cover-hides-footnote: true` leaks the entry.

- **fix: a footnote bibliography no longer prevents convergence** ([#395](https://github.com/touying-typ/touying/issues/395)) — fixed by the bibliography rework above. Verified across 30 size × breakable/detect-overflow combinations that previously warned *document did not converge within five attempts*. A CI step runs the regression with `--warnings promote`.

- fix: a bibliography no longer needs a preceding `pagebreak()` to render. `---` slide breaks inside mode-only content are handled as slide breaks, while `pagebreak()` stays a page break

- fix: `touying-get-config`'s `default:` sentinel is a private marker instead of the `type` builtin, so `default: type` is no longer a magic value, and passing a key both positionally and by name is rejected rather than silently ignored

- fix: footnotes are no longer shown before the `#pause` that reveals them ([#399](https://github.com/touying-typ/touying/pull/399), thanks @RivinHD for the initial contribution)

- fix: `hidden-parts` are flushed in the right order when a `touying-fn-wrapper` follows paused content, so a fn-wrapper no longer renders ahead of content written before it ([#400](https://github.com/touying-typ/touying/pull/400))

- fix: cover spacing ([#387](https://github.com/touying-typ/touying/issues/387), [#405](https://github.com/touying-typ/touying/pull/405))

- fix: reducer elements are covered individually rather than as one block ([#371](https://github.com/touying-typ/touying/issues/371), [#381](https://github.com/touying-typ/touying/pull/381))

- fix: callback-style usage works again ([#374](https://github.com/touying-typ/touying/issues/374), [#380](https://github.com/touying-typ/touying/pull/380))

- fix: empty output slides are no longer indexed when adding last-page metadata ([#382](https://github.com/touying-typ/touying/pull/382))

- fix: wrong type in pdfpc commands ([#407](https://github.com/touying-typ/touying/pull/407), thanks @vilaureu)

- fix: `touying-diagram` binding and the CeTZ docs example repaired ([#389](https://github.com/touying-typ/touying/pull/389))

- i18n: French translation for the outline ([#396](https://github.com/touying-typ/touying/pull/396), thanks @tarikgraba)

- theme(dewdrop): `outline-title` is gone from the theme's documented parameter list. It was never an actual parameter of `dewdrop-theme`; the outline slide's title is its `title` argument

- theme(stargazer): list markers are positioned correctly ([#393](https://github.com/touying-typ/touying/pull/393), thanks @joseph-tao)

- theme(stargazer): it also documented `footer` and `footer-right` when never using those.

### Documentation

Almost every page was touched. The largest items:

- **docs: new [Article Mode](https://touying-typ.github.io/docs/integration/article-mode) tutorial** #TODO! As it is mainly meant for integrating other themes for article style documents it goes into integration.

- **docs: new [Speaker Notes](https://touying-typ.github.io/docs/tutorials/speaker-notes) tutorial** (English and Chinese), covering where notes attach, the second screen, presenter view, per-subslide notes, markdown notes for pdfpc, exporting, and styling the panel. 
- docs: [Custom Themes](https://touying-typ.github.io/docs/themes/custom) gains sections on customizing the speaker-note panel, making a special slide's title discoverable with a hidden heading, and why helper components should use `touying-fn-wrapper-raw`. [Build Your Own Theme](https://touying-typ.github.io/docs/tutorials/build-your-own-theme) gains a matching "Customizing the Notes" section.
- docs: [Cover Function](https://touying-typ.github.io/docs/tutorials/dynamic/cover) rewritten around `alpha-changing-cover` and `color-changing-cover`, with a new section on `cover-hides-footnote` explaining why `auto` recognises a hiding cover by identity, so a hand-written `(self: none, body) => hide(body)` is classified visual-only and its footnotes appear before the reveal.
- docs: [Sections and Headings](https://touying-typ.github.io/docs/tutorials/sections) now separates the labels that change how a heading is presented from the labels that filter by output mode, and warns that `<touying:hidden>` does not suppress the slide or its number, which `config-common(freeze-slide-counter: true)` does.
- docs: [Counters](https://touying-typ.github.io/docs/tutorials/progress/counters) and the sections page corrected on `appendix`, which freezes only the denominator (`utils.last-slide-number`) while `utils.slide-counter` keeps advancing, so an appendix footer reads `4 / 2`.
- docs: [Complex Animations](https://touying-typ.github.io/docs/tutorials/dynamic/complex) explains what can be nested inside `touying-fn-wrapper-raw` versus `touying-fn-wrapper`, including the `.with(..)` trap for theme authors.
- docs: [Waypoints](https://touying-typ.github.io/docs/tutorials/dynamic/waypoints) documents hierarchical labels, where `<part:intro>` and `<part:main>` combine under `<part>`, and corrects `start`, which belongs on `#waypoint` rather than on `#uncover`.
- docs: [Fit To](https://touying-typ.github.io/docs/tutorials/utilities/fit-to) brought in line with the real signatures of `fit-to-height` and `fit-to-width`, where `height`/`width` are named with a `1fr` default, positional is still accepted, and `reflow` and `force-height` exist.
- docs: [Layout](https://touying-typ.github.io/docs/tutorials/layout) and the FAQ corrected. `detect-overflow` emits a warning and compilation continues; it does not `panic()`.
- docs: [pdfpc](https://touying-typ.github.io/docs/external/pdfpc) documents `end-slide`, `save-slide` and `hidden-slide` alongside speaker notes, plus bundle export. [touying-exporter](https://touying-typ.github.io/docs/external/touying-exporter) documents `utils.get-input`.
- docs: [CeTZ integration](https://touying-typ.github.io/docs/integration/cetz) drops the stale `(uncover(..),)` array syntax from the callback-style example, and the FAQ's fletcher example likewise.
- docs: the [FAQ](https://touying-typ.github.io/docs/faq) was substantially reworked, covering the bibliography, section-slide bodies, `touying-fn-wrapper-raw`, the cover methods, `"h"` and `"!"` subslide specs, second-screen alignments, and Tinymist in place of the discontinued Typst Preview extension.
- docs: new [Article Mode](https://touying-typ.github.io/docs/integration/article-mode) page covering the export modes, article themes and `available-fields`, writing for both outputs, recalling animated content, and floating images.
- docs: new [Output Modes](https://touying-typ.github.io/docs/tutorials/output-modes) page gathering the four export modes, the four mode markers and the `<touying:..>` section labels in one place. The handout page keeps handout mode itself and links to it.
- docs: [Complex Animations](https://touying-typ.github.io/docs/tutorials/dynamic/complex) documents `animate` (placement versus styling, priority, and that the last effect written wins), `swap` and its `stretch`, `animate-hidden` / `animate-removed`, `touying-render`, `touying-recall`, and the callback-style variants.
- docs: large Chinese translation pass covering the theme pages, FAQ, settings, sections, navigation, and the new speaker-notes page. The Chinese `settings` and `custom` pages document article mode.

### Miscellaneous

- **refactor: `src/core.typ` is split into modules.** The 6288-line file becomes `src/core/parser.typ`, `src/core/animation.typ`, `src/core/slides.typ`, `src/core/blocks.typ`, `src/core/waypoints.typ` and additionally `src/core/article.typ`, with `src/slides.typ` replaced by `src/entrypoint.typ` and the new `src/bundle.typ` holding the bundle-export helpers. `src/exports.typ` is reorganised along the same lines. The public API is unaffected except where noted above, but anything importing `touying/src/core.typ` directly has to be updated.
- **refactor: content-tree handling is one layer, `src/core/tree.typ`.** Recognising what a piece of content is, taking it apart and putting it back together was written out in about thirty places, which had drifted apart: label handling differed per call site, several walks could not see through a `styled` node, and the two cover methods were 200-line near-copies. The new module knows nothing about touying and imports nothing, so anything can use it. `shape-of` classifies how a node holds its sub-content, `children-of` and `rebuild` are guaranteed to round-trip it, and `map-tree` walks with an identity short-circuit. Most of the fixes listed above are consequences rather than separate patches. Moved out of `utils`: the `is-*` predicates, the `typst-builtin-*` handles, `reconstruct*`, `trim`, `label-it`. `core/subslides.typ` takes visibility-spec resolution (`check-visible`, `resolve-negative-subslides`, `last-required-subslide`, …) and `resolve-waypoints` joins `core/waypoints.typ`. The old names stay in `utils`: the ones returning content forward with a deprecation warning, the rest panic naming the new module.
- refactor: block rendering, waypoint-to-integer resolution, the equation/mitex/raw paths and the article-mode scanning functions were each unified into one implementation rather than several near-duplicates.
- test: reference renders regenerated for Typst 0.15.0 / tytanic 0.4.0 layout drift. New suites for article mode (presentation, handout and article variants of one source), `recall-content`, `render-subslides`, `mode-never`, `notes-second-screen`, `pdfpc`, `cover-citation`, and the #395, #408 and #415 regressions.

### Theme Migration Guide

**For theme developers upgrading to v0.8.0:**

1. **Style the body through `setting:`, not by wrapping it.** All bundled themes now pass their alignment and decoration as `touying-slide(setting: ..)` rather than wrapping the body in `align(..)` or a block. Wrapping hides the body from the parser, which breaks animation counting and article-mode linearization:
   ```typst
   // Before
   touying-slide(self: self, config: config, align(center + horizon, body))

   // After
   touying-slide(self: self, config: config, setting: align.with(center + horizon), body)
   ```
2. **Register a `notes-fn`.** Replace any `config-methods(show-only-notes: ..)` renderer override with `config-common(notes-fn: ..)` built on `touying-notes`; roughly ten lines of colours per theme. The `config-common(show-only-notes: ..)` flag is a separate option and is unchanged.
3. **Give special slides a hidden heading** so their title is discoverable by `utils.display-current-heading`. Both the slide header and the notes panel read from it:
   ```typst
   place(hide(heading(
     level: self.slide-level, title,
     bookmarked: false, outlined: false, numbering: none,
   )))
   ```
4. **Prefer `touying-fn-wrapper-raw` for helper components** that need `self`, and pass the body as a positional argument so animations inside it are parsed:
   ```typst
   #let tblock(title: none, it) = touying-fn-wrapper-raw(_tblock.with(title: title), it)
   ```
5. **Do not paint behind the notes half** through `config-page(background: ..)`. Use `touying-notes`' `fill` and `header-fill`.

## v0.7.4

### Features

- feat: adds `touying-reduce` which automatically looks up reducer bindings given a package ([#363](https://github.com/touying-typ/touying/pull/363))
- feat(i18n): add Polish locale for outline message ([#372](https://github.com/touying-typ/touying/pull/372))
- feat: Left/Right keyboard navigation support ([#352](https://github.com/touying-typ/touying/pull/352))
- feat: add `grid-size` parameter to `lazy-layout` for quantized position grouping, improving robustness of column/row detection
- feat: add `components.full-width-block` component that spans the full page width by cancelling horizontal margins

### Fixes

- fix (minor breaking change): set `lazy-layout` default to `false` for `cols`
- fix: handle missing `fn` field in mark warning message gracefully
- fix: `hide` doing unexpected things to headings ([#366](https://github.com/touying-typ/touying/pull/366))
- fix: export `touying-fn-wrapper-raw` as part of the public API ([#362](https://github.com/touying-typ/touying/pull/362))
- fix: improved mark-warning, now also displayed as `magic.warning` when `enable-mark-warning` is `false` ([#348](https://github.com/touying-typ/touying/pull/348))
- fix: warnings now emitted via `uniwarn` ([#359](https://github.com/touying-typ/touying/pull/359))

## v0.7.3

### Minor Breaking Changes

- **feat!: always attach `#speaker-note[]` to the previous slide & default `receive-body-for-new-*-slide-fn` to `false`** ([#354](https://github.com/touying-typ/touying/pull/354))
  - `#speaker-note[]` now always attaches to the **slide above it**, regardless of how that slide was created (explicit slide calls, heading-triggered section slides, or normal content slides). This eliminates the common pitfall where a `#speaker-note[]` placed after a slide would silently create an unwanted empty "ghost" slide.
  - `receive-body-for-new-section-slide-fn` and its variants are now **defaulted to `false`** (previously `true`).

### Migration Guide

If you relied on content after `= Section` headings being absorbed into the section slide body, explicitly set `receive-body-for-new-section-slide-fn: true` in your `config-common(...)`.

### Features

- feat: `item-by-item-fn` and presets for it ([#347](https://github.com/touying-typ/touying/pull/347))
- feat: improved `custom-progressive-outline` and new `section-relationship` and some other things ([#345](https://github.com/touying-typ/touying/pull/345))
- feat: better lazy-layout for mixed layouts ([#355](https://github.com/touying-typ/touying/pull/355))
- feat: add `cols` as alias of `side-by-side` and export some components `cols`, `lazy-xxx` to outside ([#356](https://github.com/touying-typ/touying/pull/356))
- theme(metropolis): add outline-slide for metropolis ([#349](https://github.com/touying-typ/touying/pull/349))
- feat: add warning for empty slide content height detection

### Documentation

- docs: add multiple columns example and improve docs structure

## v0.7.1

### Features

- feat(agents): `breakable` and `clip` options to avoid slide overflow ([#336](https://github.com/touying-typ/touying/pull/336))
- feat(components): add `lazy-v` (`lazy-h`) and `lazy-layout` for equalizing multi-column (-row) block heights (widths) ([#339](https://github.com/touying-typ/touying/pull/339))
- feat: additional `contact` and `extra` field in `config-info` ([#342](https://github.com/touying-typ/touying/pull/342))
- feat: `touying-get-config` function ([#333](https://github.com/touying-typ/touying/pull/333))

### Fixes

- fix: fix `fit-to-height` and `size-to-pt` and allow text reflow ([#332](https://github.com/touying-typ/touying/pull/332))
- fix: fix waypoint markers ([#341](https://github.com/touying-typ/touying/pull/341))


## v0.7.0

### Features

- **major feature:** a named waypoint feature ([#298](https://github.com/touying-typ/touying/pull/298))
- feat(waypoint): start param and Waypoints in handout-subslides ([#304](https://github.com/touying-typ/touying/pull/304))
- feat: auto, "h"-here string and inverse function for string subslide-numbers and waypoints ([#301](https://github.com/touying-typ/touying/pull/301))
- feat: implicitly allow fn-wrapper based animation functions via reducer ([#300](https://github.com/touying-typ/touying/pull/300))

### Fixes

- fix: fix cover-with-rect breaking long lines of text when partially hidden and fallback functions for color/alpha cover ([#328](https://github.com/touying-typ/touying/pull/328))
- fix: using explicit numbering in display-current-heading when style=auto ([#329](https://github.com/touying-typ/touying/pull/329))
- fix: fix ghost slides with show rules. Fix proper consistent handling of show rules and defer keyword ([#317](https://github.com/touying-typ/touying/pull/317))
- fix: alert not delayed ([#316](https://github.com/touying-typ/touying/pull/316))
- fix: remove redundant nested text call ([#324](https://github.com/touying-typ/touying/pull/324))
- fix: function alternatives-match takes into account parameter stretch ([#320](https://github.com/touying-typ/touying/pull/320))
- fix: correctly handle page margin merge/precedence ([#322](https://github.com/touying-typ/touying/pull/322))
- fix: fix cover spacing issues surrounding lists ([#303](https://github.com/touying-typ/touying/pull/303))
- fix: correctly parses negative subslide indices (ints, arrays) for handout-subslides ([#307](https://github.com/touying-typ/touying/pull/307))
- fix: slide function does not update via scoped import ([#310](https://github.com/touying-typ/touying/pull/310))

Thanks for the contributions from [@zral0kh](https://github.com/zral0kh), [@Andrew15-5](https://github.com/Andrew15-5), [@navdeeprana](https://github.com/navdeeprana), and [@Cemoixerestre](https://github.com/Cemoixerestre).

## v0.6.3

A major bugfix release, fixing many long-standing bugs and introducing many practical features.

### Features

- **feat: add `#jump(n, relative: bool)` as unified animation control; redefine `#pause`/`#meanwhile` as sugar**
- feat: add `#handout-only` for inline content and `<touying:handout>` label for handout-exclusive slides ([#286](https://github.com/touying-typ/touying/pull/286))
- feat: add `handout-subslides` to control which subslides appear in handout mode ([#288](https://github.com/touying-typ/touying/pull/288))
- feat: add `#touying-raw` for animated code block reveals ([#283](https://github.com/touying-typ/touying/pull/283))
- feat: add full-screen speaker notes mode with slide thumbnail (`show-only-notes`) ([#281](https://github.com/touying-typ/touying/pull/281))
- feat: support arbitrary aspect ratios (e.g. 16-10) across all themes and speaker-note second screen ([#280](https://github.com/touying-typ/touying/pull/280))
- feat: add `#item-by-item` animation for list, enum, and terms ([#278](https://github.com/touying-typ/touying/pull/278))
- feat(recall): add subslide parameter to `#touying-recall` ([#285](https://github.com/touying-typ/touying/pull/285))
- feat: add `default-composer` to config-common for global slide layout configuration ([#284](https://github.com/touying-typ/touying/pull/284))
- feat: add `cover-fn` parameter to `uncover` for external package integration (e.g. Fletcher) ([#267](https://github.com/touying-typ/touying/pull/267))
- feat: minislides can be displayed inline ([#228](https://github.com/touying-typ/touying/pull/228))
- theme: improve appearance of long author lists in university and stargazer theme ([#242](https://github.com/touying-typ/touying/pull/242))
- theme(simple): make simple-theme respect color configuration for deco-format ([#252](https://github.com/touying-typ/touying/pull/252))
- theme(aqua,stargazer): add extra parameter to title-slide ([#291](https://github.com/touying-typ/touying/pull/291))

### Fixes

- fix: prevent ghost-slide blank pages from `touying-set-config` anchor regression ([#289](https://github.com/touying-typ/touying/pull/289))
- fix: styled content on first slide no longer creates extra slides ([#287](https://github.com/touying-typ/touying/pull/287))
- fix: remove unoutlined headings from navigation
- fix: fix `#meanwhile` being ignored inside grid cells, boxes, and other containers ([#274](https://github.com/touying-typ/touying/pull/274))
- fix: fix `config: parameter` silently ignored across all themes ([#273](https://github.com/touying-typ/touying/pull/273))
- fix: fix slides after `#show`/`#set` rules not rendering subsequent slides ([#268](https://github.com/touying-typ/touying/pull/268))
- fix: fix title page PDF page label causing pdfpc presenter notes mismatch ([#277](https://github.com/touying-typ/touying/pull/277))
- fix: fix duplicate label error for labeled footnotes with `#pause` animations ([#275](https://github.com/touying-typ/touying/pull/275))
- fix: fix `#pause` inside `#speaker-note` body (nested list items) ([#282](https://github.com/touying-typ/touying/pull/282))
- theme(dewdrop): fix body content under level-1 heading was silently dropped ([#279](https://github.com/touying-typ/touying/pull/279))
- theme(stargazer): update stargazer theme margins and fix [#259](https://github.com/touying-typ/touying/pull/259)

### Documentation

- **docs(BIG CHANGE): refactor docs website and add references page**
- docs: reduce README noise, improve first impression ([#297](https://github.com/touying-typ/touying/pull/297))
- docs: restructure docs + add docs-preview CI for PRs ([#296](https://github.com/touying-typ/touying/pull/296))
- docs: comprehensive docstring improvements across all source files ([#294](https://github.com/touying-typ/touying/pull/294))

### Miscellaneous

- chore: add `copilot-setup-steps.yml` and improve `copilot-instructions.md` ([#292](https://github.com/touying-typ/touying/pull/292))

### Theme Migration Guide

**For theme developers upgrading to v0.6.3:**

1. **Move `config` to the last position in `utils.merge-dicts`** to allow user overrides:
   ```typst
   // Before
   self = utils.merge-dicts(self, config, config-page(...))
   
   // After
   self = utils.merge-dicts(self, config-page(...), config)
   ```

2. **Replace `paper` with `utils.page-args-from-aspect-ratio`** to support arbitrary aspect ratios:
   ```typst
   // Before
   config-page(paper: "presentation-" + aspect-ratio, ...)
   
   // After
   config-page(..utils.page-args-from-aspect-ratio(aspect-ratio), ...)
   ```

## v0.6.2

### Features

- feat: allow customisation of `components.checkerboard` ([#161](https://github.com/touying-typ/touying/pull/161))

### Fixes

- fix: support ratio and relative margins for full-width headers ([#256](https://github.com/touying-typ/touying/pull/256))
- fix: fix `magic.bibliography-as-footnote` in Typst 0.14 ([#249](https://github.com/touying-typ/touying/pull/249))
- fix: theorion package is broken with Typst 0.14.0 ([#237](https://github.com/touying-typ/touying/pull/237))
- fix: update `components.typ` and pass named arguments to grid ([#207](https://github.com/touying-typ/touying/pull/207))
- fix: fix `#meanwhile` in cetz ([#205](https://github.com/touying-typ/touying/pull/205))
- fix: documentation contains unclosed raw text error ([#187](https://github.com/touying-typ/touying/pull/187))
- fix: use correct circle symbol ([#171](https://github.com/touying-typ/touying/pull/171))
- fix: use regex to override colors of equations ([#167](https://github.com/touying-typ/touying/pull/167))
- fix: `show-hide-set-list-marker-none` with full enum ([#157](https://github.com/touying-typ/touying/pull/157))
- fix: remove dump and label-it function for better cache

### Miscellaneous

- docs: update README, bump versions of deps, and fix comment docs
- ci: add more tests, bump versions of `tytanic`, and update typstyle workflow ([#221](https://github.com/touying-typ/touying/pull/221), [#261](https://github.com/touying-typ/touying/pull/261))


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
