// Test for progressive-outline and custom-progressive-outline features including
// the hide-other-sections-subsections parameter (Beamer-style hideothersubsections).

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
)

// ── Slide 1: plain progressive-outline (default, level 1) ─────────────────────
// We are on the first section's slide, so section 1 is "active".

= Section 1

== Section 1 Outline <touying:hidden>

#components.progressive-outline()

// ── Slides 2-3: subsections of Section 1 ──────────────────────────────────────

== Subsection A

Content A.

== Subsection B

Content B.

// ── Slide 4: start of Section 2, custom-progressive-outline with default opts ─
// Section 2 should be active; Section 1 and 3 should be covered (alpha).

= Section 2

== Section 2 Outline (default) <touying:hidden>

#components.custom-progressive-outline(level: 1)

// ── Slides 5-6: subsections of Section 2 ──────────────────────────────────────

== Subsection C

Content C.

== Subsection D

Content D.

// ── Slide 7: third section ────────────────────────────────────────────────────

= Section 3

== Section 3 Outline (hide-other-sections-subsections) <touying:hidden>

// hide-other-sections-subsections: subsections of Section 1 and 3 should be
// invisible; subsections C and D of Section 2 should be visible (with alpha
// since we are not currently on their pages).
#components.custom-progressive-outline(hide-other-sections-subsections: true)

== Subsection E

// On this subsection's slide, Subsection E should be the active (non-covered)
// subsection when viewing an outline here, while F is still covered.
#components.custom-progressive-outline(hide-other-sections-subsections: true)

== Subsection F

Content F.
