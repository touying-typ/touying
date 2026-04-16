# Touying - AI Coding Agent Instructions

## Project Overview

Touying is a Typst package for creating presentation slides. It is a powerful alternative to LaTeX Beamer with better performance, achieved by avoiding `counter` and `context` for `#pause` animations.

## Repository Layout

```
lib.typ              # Entry point — re-exports src/exports.typ
src/
  core.typ           # Animation engine, slide rendering
  utils.typ          # Shared helpers (merge-dicts, display-current-heading, …)
  configs.typ        # config-common, config-colors, config-page, config-info, …
  exports.typ        # Public API surface
  components.typ     # Reusable slide components (cols, …)
themes/              # 6 built-in themes: simple, metropolis, dewdrop, university, aqua, stargazer
examples/            # Theme usage examples (excluded from package)
tests/
  features/          # Feature regression tests (test.typ + ref/*.png)
  themes/            # Theme regression tests
  examples/          # Full-presentation tests
typst.toml           # Package manifest (name, version, compiler constraint)
```

## Development Workflow

### Tools

Three tools must be available in your environment (all installed by `.github/workflows/copilot-setup-steps.yml`):

| Tool | Command | Purpose |
|------|---------|---------|
| Typst CLI | `typst` | Compile `.typ` files |
| tytanic | `tt` | Visual regression test runner |
| typstyle | `typstyle` | Official Typst code formatter |

### Testing with tytanic

```bash
# Run the full test suite (compares rendered PNGs against ref/ images)
tt run

# Run only a subset of tests
tt run tests/features/animation

# Update reference images after intentional visual changes
tt update

# List all tests
tt list
```

- tytanic automatically locates the project root via `typst.toml`
- Test output goes to `tests/**/out/`, diffs to `tests/**/diff/`
- Reference images are committed in `tests/**/ref/`
- PPI for reference images: 72 (set in `typst.toml` under `[tool.tytanic]`)

**When to run `tt update`**: After making intentional visual changes (e.g., layout, theme colors), regenerate the reference images with `tt update` and commit the updated `ref/*.png` files.

### Formatting with typstyle

**Always format modified `.typ` files before finalising a PR.** The CI enforces this via `git diff --exit-code`.

```bash
# Format one or more files in-place
typstyle -i src/core.typ src/utils.typ

# Format an entire directory recursively
typstyle -i themes/

# Format all .typ files in the project
typstyle -i src/ themes/ tests/
```

### Compiling a single file (quick check)

```bash
# No build step required — Touying is a pure Typst package
typst compile --root . tests/features/animation/test.typ /tmp/out.pdf
```

## Typst Language Essentials

### Syntax Modes

| Mode | Trigger | Example |
|------|---------|---------|
| Markup (default) | — | `*bold*`, `_italic_`, `= Heading` |
| Code | `#` prefix | `#let x = 1`, `#if cond { … }` |
| Math | `$…$` | `$x^2 + y$` |

> **Always use Typst's native math syntax**, not LaTeX. Typst math is more intuitive.

### Naming: kebab-case only

All identifiers (variables, functions, parameters) use **kebab-case**:

```typst
#let my-variable = 42
#let calculate-sum(a, b) = a + b
```

snake_case, camelCase, and PascalCase are **prohibited**.

### Reserved identifiers to avoid shadowing

Do not bind variables or parameters to Typst built-in names. Key ones to avoid:

- **Types**: `none`, `auto`, `bool`, `int`, `float`, `str`, `content`, `function`, `array`, `dictionary`, `color`, `length`, `ratio`, `angle`, `stroke`, `alignment`, `direction`
- **Layout**: `columns`, `grid`, `table`, `stack`, `box`, `block`, `place`, `align`, `pad`, `measure`, `layout`, `repeat`
- **Text/lists**: `text`, `par`, `list`, `enum`, `item`, `quote`, `raw`, `strong`, `emph`
- **Document**: `document`, `page`, `heading`, `outline`, `figure`, `footnote`
- **Graphics**: `math`, `rect`, `circle`, `polygon`, `rotate`, `scale`, `fill`, `gradient`
- **I/O**: `read`, `include`, `image`, `link`, `ref`, `cite`

When wrapping these, use a `touying-` prefix: `touying-grid`, `touying-table`.

### Pure functions & caching

Typst functions are **pure** — they cannot mutate external state:

```typst
// ✗ Invalid: cannot push to an external array inside a function
// ✗ Invalid: cannot assign to an external variable

// ✓ Return new values instead
#let add-item(items, new) = items + (new,)
```

Typst automatically **caches** function call results by input. Avoid creating many tiny functions with trivial bodies — inline code is usually preferable to prevent cache bloat.

## Key API Patterns

### Slide creation

```typst
// Heading-based (preferred)
= Section           // section slide
== Subsection       // subsection slide
=== Slide title     // content slide

// Explicit function call
#slide[Content]
#slide(composer: (1fr, 1fr))[Left column][Right column]
```

### Animation

```typst
#pause                        // incremental reveal
#meanwhile                    // parallel track with #pause
#uncover("2-")[content]       // visible from subslide 2 onward
#only("1,3")[content]         // visible only on subslides 1 and 3
#alternatives[Option A][Option B]

// Callback style (access self.subslide)
#slide(self => {
  let (uncover, only, alternatives) = utils.methods(self)
  uncover("2-")[Revealed on 2+]
})
```

### Configuration

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Title], author: [Author]),
  config-colors(primary: blue),
  config-common(handout: false),
)

// Per-slide config override
#slide(
  config: utils.merge-dicts(
    config-colors(primary: red),
    config-common(handout: true),
  )
)[Content]
```

Configuration functions:
- `config-colors` — color scheme
- `config-common` — global flags (`handout`, `frozen-counters`, `show-only-notes`, …)
- `config-info` — document metadata (title, author, date, …)
- `config-methods` — animation method overrides
- `config-page` — page layout

### External package integration (touying-reducer)

```typst
// CeTZ
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#cetz-canvas({
  import cetz.draw: *
  rect((0,0), (5,5))
  (pause,)
  circle((2.5,2.5), radius: 1)
})

// Fletcher
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)
```

### Speaker notes

```typst
#speaker-note[
  + Remind audience of previous slide
  + Key takeaway: …
]
```

## Documentation Standard

Use `///` docstrings for all public functions:

```typst
/// One-line description.
///
/// Example:
/// ```typst
/// #my-fn(arg1: value)
/// ```
///
/// - arg1 (str): Description.
/// - arg2 (int | none): Optional count, defaults to `none`.
///
/// -> content
```

Types use Typst names (`str`, `int`, `content`, `function`, …); union types use `|`.

## Special Heading Labels

Touying recognises these heading labels for slide control:

| Label | Effect |
|-------|--------|
| `<touying:hidden>` | Hide slide completely |
| `<touying:skip>` | Skip slide in output |
| `<touying:unnumbered>` | No slide number |
| `<touying:unoutlined>` | Exclude from outline |
| `<touying:unbookmarked>` | No PDF bookmark |
| `<touying:handout>` | Show only in handout mode |

## Performance Notes

- Avoid `counter` and `context` inside animation logic (causes recompilation).
- Use `touying-reducer` for external animated content (CeTZ, Fletcher, …).
- Prefer functional composition over mutable state.
- Only extract helpers into named functions when the caching benefit is real.