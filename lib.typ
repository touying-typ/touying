/// // #image("https://github.com/user-attachments/assets/58a91b14-ae1a-49e2-a3e7-5e3a148e2ba5")
///
/// #link("https://github.com/touying-typ/touying")[Touying] (投影 in chinese, /tóuyǐng/, meaning projection) is a user-friendly, powerful and efficient package for creating presentation slides in Typst. Partial code is inherited from #link("https://github.com/andreasKroepelin/polylux")[Polylux]. Therefore, some concepts and APIs remain consistent with Polylux.
///
/// Touying provides automatically injected global configurations, which is convenient for configuring themes. Besides, Touying does not rely on `counter` and `context` to implement `#pause`, resulting in better performance.
///
/// If you like it, consider #link("https://github.com/touying-typ/touying")[giving a star on GitHub]. Touying is a community-driven project, feel free to suggest any ideas and contribute.
///
/// == Example
///
/// Split slides by headings #link("https://touying-typ.github.io/docs/sections")[document]
///
/// #example(```
/// #import "@preview/touying:0.6.1": *
/// #import themes.dewdrop: *
///
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { rgb("#c0caf5") } else { black };
/// >>>
/// >>> #show: dewdrop-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// <<< #show: dewdrop-theme.with(aspect-ratio: "16-9")
///
/// = Section
///
/// == Subsection
///
/// === Title
///
/// Hello, Touying!
/// ```)
///
/// == Example
///
/// `#pause` and `#meanwhile` animations #link("https://touying-typ.github.io/docs/dynamic/simple")[document]
///
/// #example(```
/// ```)

#import "src/exports.typ": *
#import "themes/themes.typ"