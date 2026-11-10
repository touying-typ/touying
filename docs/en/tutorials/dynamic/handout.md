---
sidebar_position: 6
---

# Handout Mode

Handout mode collapses all animation subslides into a single page per logical slide, making it easy to produce a printable or distributable version of your presentation.

## Enabling Handout Mode

```typst
config-common(handout: true)
```

Place this inside your theme setup:

```example
#import "@preview/touying:0.8.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: true),
)

= Title

== Animated Slide

First item.

#pause

Second item (won't generate a separate page in handout mode).

#pause

Third item.
```

By default, handout mode keeps only the **last** subslide of each slide.

Handout mode can also be set with `config-common(export-mode: "handout")`, which can in turn be passed on the command line with `--input export-mode=handout` without touching the source file at all. See [Output Modes](../output-modes).

## Choosing Which Subslide to Keep

You can choose a specific subslide (or a set of subslides) to keep in handout output with `handout-subslides`:

```typst
// Keep only the first subslide (useful for "before" snapshots)
config-common(handout: true, handout-subslides: 1)

// Keep the first and last subslides
config-common(handout: true, handout-subslides: (1, -1))

// Keep a range expressed as a string (same syntax as `only`/`uncover`)
config-common(handout: true, handout-subslides: "1-2")

// Keep the last subslide of every waypoint
config-common(handout: true, handout-subslides: "waypoints")
```

`"waypoints"` keeps one page per [waypoint](./waypoints), each showing that waypoint's final state, so a handout can follow the phases of an animation without the steps in between. It can also be one element of an array, e.g. `(1, "waypoints")`. A slide without waypoints keeps just its last subslide.

Individual waypoints can be chosen too. A bare label such as `<intro>` stands for the *last* subslide of that waypoint, where its content is fully shown, so `handout-subslides: (<intro>, <result>)` keeps one page per waypoint. Use `get-first(<intro>)` for the first subslide instead. Range markers keep every subslide they span: `from-wp(<intro>)` the rest of the slide from the waypoint on, `until-wp(<intro>)` everything before it, and `not-wp(not-wp(<intro>))` exactly the subslides of that one waypoint.

## Handout-only Slides

Use the `<touying:handout>` label to create slides that appear **only** in handout mode and are hidden during normal presentation:

```typst
== Extra Notes for Handout <touying:handout>

This slide is included when `handout: true` but invisible otherwise.
```

## Content for One Mode Only

`#handout-only[..]`, `#presentation-only[..]`, `#slides-only[..]` and `#article-only[..]` keep a piece of content out of the modes it does not suit. They are covered in [Output Modes](../output-modes).

## Workflow Tip

A common workflow is to keep `handout: false` (the default) while presenting, then switch to `handout: true` when exporting a PDF to share with your audience:

```typst
// During presentation
#show: my-theme.with(config-common(handout: false))

// When building the handout PDF
#show: my-theme.with(config-common(handout: true))
```

If you would rather not touch the source file at all, use `--input export-mode=handout` from the command line instead, as noted above.
