// Convenience re-exports for building custom themes.
// These are available in custom.typ as `theme-components.*`.


#import "../src/utils.typ": (
  // ── Slide counters & progress ────────────────────────────────────────────────
  slide-counter,
  last-slide-counter,
  last-slide-number,
  touying-progress,

  // ── Heading & section display ────────────────────────────────────────────────
  current-heading,
  short-heading,
  reconstruct-heading,
  display-current-heading,
  display-current-heading-number,
  display-current-short-heading,
  section-relationship,

  // ── Text & info helpers ──────────────────────────────────────────────────────
  capitalize,
  titlecase,
  call-or-display,
  display-info-date,

  // ── Layout ───────────────────────────────────────────────────────────────────
  fit-to-width,
  fit-to-height,

  // ── Visual 
  alert-with-primary-color,
)

#import "../src/components.typ": (
  left-and-right,
  adaptive-columns,
  page-container,

  // ── Progress bars & navigation ───────────────────────────────────────────────
  progress-bar,
  mini-slides,
  simple-navigation,

  // ── Outline components ───────────────────────────────────────────────────────
  progressive-outline,
  custom-progressive-outline,

  // ── Decorative ───────────────────────────────────────────────────────────────
  knob-marker,
  checkerboard,
)

#import "../src/core.typ": (
  LeftRightNavigation,
)

