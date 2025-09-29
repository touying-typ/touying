# Touying - AI Coding Agent Instructions

## Project Overview
Touying is a Typst package for creating presentation slides. It provides a powerful, efficient alternative to LaTeX Beamer with better performance through avoiding `counter` and `context` for `#pause` animations.

## Architecture
- **Entry point**: `lib.typ` imports from `src/exports.typ`
- **Core modules**: `src/core.typ` (animations, slides), `src/utils.typ` (utilities), `src/configs.typ` (configuration)
- **Themes**: `themes/` directory with 6 themes (simple, metropolis, dewdrop, university, aqua, stargazer)
- **Testing**: Visual regression testing using `tytanic` (tt) tool comparing rendered PDFs against reference images

## Key Patterns

### Slide Creation
```typst
// Heading-based (recommended)
= Section        // Creates section slide
== Subsection    // Creates subsection slide
=== Title        // Creates content slide

// Function-based
#slide[Content]
#slide(composer: (1fr, 1fr))[Left][Right]
```

### Animation System
```typst
// Basic animations
#pause                    // Reveals content incrementally
#meanwhile               // Parallel reveals with #pause

// Selective display
#uncover("2-")[content]  // Shows from slide 2 onward
#only("1,3")[content]    // Shows only on slides 1 and 3
#alternatives[Option A][Option B]  // Choice between alternatives

// Advanced
#slide(repeat: 3, self => {
  let (uncover, only, alternatives) = utils.methods(self)
  // Use methods with self.subslide
})
```

### Theme Usage
```typst
#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    author: [Author],
  ),
)
```

### External Package Integration
```typst
// CeTZ diagrams
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#cetz-canvas({
  import cetz.draw: *
  rect((0,0), (5,5))
  (pause,)  // Animation point
  circle((2.5,2.5), radius: 1)
})

// Fletcher diagrams
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)
```

## Configuration System
- `config-colors`: Color scheme customization
- `config-common`: Global settings (frozen-counters, handout mode, etc.)
- `config-info`: Document metadata (title, author, date)
- `config-methods`: Animation method overrides
- `config-page`: Page layout settings

## Development Workflow

### Testing
Tytanic (tt) is the command-line testing tool for visual regression testing. It compares rendered PDFs against reference images.

```bash
# Install tytanic testing tool
cargo binstall tytanic@0.2.2 -y

# Run visual regression tests
tt run

# Tests compare rendered PDFs in tests/**/out/ against reference images in tests/**/ref/
# Diffs saved to tests/**/diff/ on failures
```

**Tytanic Usage:**
- Install to a directory in your `$PATH` to run with `tt` command
- Automatically detects project root by looking for `typst.toml` manifest file
- For custom project root: `tt list --root ./path/to/root/` or set `TYPST_ROOT` environment variable
- Available commands: `tt new`, `tt run`, `tt list` (see tests guide for details)

### Building
- No build step required - pure Typst package
- Use Typst CLI for development: `typst compile example.typ`

### Code Organization
- **New features**: Add to `src/core.typ` or create new module in `src/`
- **Themes**: Follow pattern in `themes/simple.typ` - define slide function with config/repeat/setting/composer parameters
- **Utilities**: Add to `src/utils.typ` with documentation
- **Tests**: Create `tests/features/feature-name/` with test.typ, ref/, out/, diff/ directories

## Common Patterns

### Callback Functions
Many functions accept callbacks for dynamic behavior:
```typst
#slide(self => [
  At subslide #self.subslide of #self.subslide-total
])
```

### Method Extraction
```typst
#slide(self => {
  let (uncover, only, alternatives) = utils.methods(self)
  // Now use uncover("2-"), only("1"), etc.
})
```

### Configuration Merging
```typst
#slide(
  config: utils.merge-dicts(
    config-colors(primary: red),
    config-common(handout: true)
  )
)[Content]
```

### Speaker Notes
```typst
#speaker-note[
  + Note for presenter
  + Won't appear in slides unless configured
]
```

## File Structure Conventions
- `src/`: Core implementation modules
- `themes/`: Theme definitions
- `examples/`: Theme usage examples
- `tests/examples/`: Full presentation tests
- `tests/features/`: Feature-specific tests
- `tests/themes/`: Theme-specific tests

## Performance Considerations
- Avoid `counter` and `context` in animation implementations
- Use `touying-reducer` pattern for external package integration
- Prefer functional composition over state mutation</content>
<parameter name="filePath">/Users/orangex4/Documents/touying/.github/copilot-instructions.md