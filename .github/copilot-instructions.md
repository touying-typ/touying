# Touying - AI Coding Agent Instructions

## Project Overview
Touying is a Typst package for creating presentation slides. It provides a powerful, efficient alternative to LaTeX Beamer with better performance through avoiding `counter` and `context` for `#pause` animations.

## Architecture
- **Entry point**: `lib.typ` imports from `src/exports.typ`
- **Core modules**: `src/core.typ` (animations, slides), `src/utils.typ` (utilities), `src/configs.typ` (configuration)
- **Themes**: `themes/` directory with 6 themes (simple, metropolis, dewdrop, university, aqua, stargazer)
- **Testing**: Visual regression testing using `tytanic` (tt) tool comparing rendered PDFs against reference images

## Typst Basics
Touying is built on Typst, a modern typesetting system. Understanding Typst's syntax modes is essential:

### Syntax Modes
- **Markup Mode** (default): For document content with simple formatting shortcuts like `*bold*`, `_italic_`, `= Heading`
- **Code Mode**: For scripting and computations, entered with `#` prefix like `#let x = 1`, `#if condition { ... }`
- **Math Mode**: For mathematical expressions, delimited by `$` like `$x^2 + y$`. **Important**: Always use Typst's native math syntax, not LaTeX math formulas. Typst math is designed to be more intuitive and powerful than LaTeX.

### Identifiers and Naming
Typst uses **kebab-case** for all identifiers (variables, functions, parameters). Examples:
- `my-variable`
- `calculate-sum`
- `config-colors`

**Strictly prohibited**: snake_case (e.g., `my_variable`), camelCase (e.g., `myVariable`), PascalCase (e.g., `MyVariable`). Always use kebab-case for consistency and readability.

### Reserved Keywords to Avoid
Avoid binding variables, functions, or parameters to Typst-reserved identifiers. Shadowing these names hides built-in functionality and can introduce confusing bugs. Keep the following frequently used keywords reserved (consult the Typst reference for the complete catalog):

- **Type identifiers**: `none`, `auto`, `bool`, `int`, `float`, `decimal`, `ratio`, `fraction`, `length`, `angle`, `datetime`, `version`, `str`, `bytes`, `array`, `dictionary`, `content`, `function`, `module`, `type`, `label`, `symbol`, `arguments`, `alignment`, `direction`, `color`, `stroke`.
- **Data loading & utilities**: `read`, `include`, `cbor`, `csv`, `json`, `toml`, `yaml`, `xml`, `image`, `video`, `embed`, `link`.
- **Document structure & metadata**: `document`, `page`, `heading`, `outline`, `figure`, `bibliography`, `cite`, `ref`, `footnote`, `note`, `sequence`.
- **Layout & composition**: `columns`, `grid`, `table`, `stack`, `box`, `block`, `place`, `align`, `pad`, `measure`, `layout`, `repeat`.
- **Text & lists**: `text`, `par`, `list`, `enum`, `item`, `term`, `quote`, `raw`, `strong`, `emph`.
- **Graphics & math**: `math`, `equation`, `cases`, `matrix`, `rect`, `square`, `circle`, `ellipse`, `polygon`, `curve`, `path`, `move`, `rotate`, `scale`, `fill`, `gradient`.

If you must introduce helper wrappers around these APIs, prefer prefixed forms such as `touying-grid` or `custom-slide`.

### Basic Syntax Examples
```typst
// Markup mode
= Section Title
== Subsection
*Bold text*, _italic text_

// Code mode
#let my-variable = 42
#if my-variable > 10 [
  Value is large
]

// Math mode
$x = (-b ± sqrt(b^2 - 4 a c)) / (2 a)$
```

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

## Documentation Standards

### Docstring Format

Touying uses triple-slash (///) docstrings for function documentation. Follow this format:

```typst
/// Brief description of the function's purpose.
///
/// Example:
///
/// ```typst
/// #function-name(arg1: value, arg2: value)
/// ```
///
/// - arg1 (type): Description of argument 1.
/// - arg2 (type): Description of argument 2.
///
/// -> return-type
```

**Key Points:**
- Start with three slashes `///`
- Provide a description
- Include a practical example (optional)
- List parameters with types and descriptions
- Specify return type with `-> type`
- Use Typst types: `none`, `auto`, `bool`, `int`, `float`, `length`, `angle`, `ratio`, `fraction`, `str`, `bytes`, `array`, `dictionary`, `function`, `content`, `color`, `stroke`, `alignment`, `direction`, `arguments`, `datetime`, `decimal`, `version`, `label`, `symbol`, `module`, `type`, etc.
- Use `|` for union types (e.g., `function | array`)

Example:

```typst
/// Touying slide function for creating animated slides.
///
/// Example:
///
/// ```typst
/// #slide[Content]
/// #slide(composer: (1fr, 1fr))[Left][Right]
/// ```
///
/// - config (dictionary): Slide configuration.
/// - repeat (auto): Number of subslides.
/// - setting (function): Slide settings.
/// - composer (function | array): Layout composer.
///
/// -> content
```

## Pure Functions and Caching

Typst functions are pure, meaning they cannot modify external variables or have side effects. This design ensures predictability and enables powerful optimizations like caching.

### Pure Function Constraints
- **No external modifications**: Functions cannot alter variables or data structures outside their scope. For example:
  - You cannot do `somethings.push(xxx)` inside a function to modify an external list.
  - You cannot assign to external variables like `x = 2` inside a function.
- **No side effects**: Functions should only compute and return values based on their inputs, without affecting the global state.

### Caching Behavior
- Typst automatically caches the results of all function calls based on their input parameters.
- This caching improves performance by avoiding redundant computations when the same function is called with identical arguments.
- **Important**: Avoid creating unnecessary small functions that don't benefit from caching. Over-abstraction can lead to cache bloat, where the cache grows excessively large and consumes memory.
- Only abstract code into functions when it provides clear reuse benefits or when caching would be advantageous. For trivial operations, inline code is often preferable to prevent cache pollution.

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
- Prefer functional composition over state mutation