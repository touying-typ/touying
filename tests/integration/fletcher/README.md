# Fletcher Integration Tests

This directory contains visual regression tests for Touying's Fletcher diagram integration.

## New Conditional Rendering Functions

Touying now supports reverse reveals and conditional rendering in `touying-reducer`:

### `until(n, ..body)`

Shows content only until slide n (inclusive), then hides it.

```typst
#fletcher-diagram(
  node((0, 0), [A]),
  node((1, 0), [B]),
  ..until(2, edge((0,0), (1,0), "->", stroke: red)),  // Visible on slides 1-2, hidden after
  pause,
  pause,
  edge((0,0), (1,0), "->", stroke: green),  // Appears on slide 3
)
```

### `at(n, ..body)`

Shows content only at slide n.

```typst
#fletcher-diagram(
  node((0, 0), [X]),
  ..at(2, node((1, 0), [Y], fill: yellow)),  // Only visible on slide 2
  pause,
  pause,
  node((2, 0), [Z]),
)
```

### `between(start, end, ..body)`

Shows content only during slides start through end (inclusive).

```typst
#fletcher-diagram(
  node((0, 0), [Start]),
  ..between(2, 3, edge((0,0), (1,0), "->", stroke: blue)),  // Visible on slides 2-3 only
  pause,
  pause,
  pause,
  node((2, 0), [End]),
)
```

## Test Structure

- `basic/` - Basic Fletcher animation with `pause`
- `until/` - Reverse reveal using `until(n)` to hide content after slide n
- `at/` - Show content only at specific slide using `at(n)`
- `between/` - Show content in a range using `between(start, end)`

## Running Tests

### Using Tytanic (recommended)

Install [Tytanic](https://github.com/tingerrr/tytanic) and run:

```bash
# Run all tests
tt run

# Run only Fletcher integration tests
tt run tests/integration/fletcher/

# Run a specific test
tt run tests/integration/fletcher/until/
```

### Manual compilation

To compile a test manually and inspect the output:

```bash
# Generate PDF
typst compile --root . tests/integration/fletcher/basic/test.typ tests/integration/fletcher/basic/out/test.pdf

# Generate PNG images (one per page)
typst compile --root . tests/integration/fletcher/basic/test.typ tests/integration/fletcher/basic/out/{n}.png
```

## Updating Reference Images

When tests change, update reference images:

```bash
# Generate new reference images
typst compile --root . tests/integration/fletcher/basic/test.typ tests/integration/fletcher/basic/ref/{n}.png
```

Or use Tytanic to update all references:

```bash
tt update
```

## Test Expectations

Each test generates multiple pages (subslides). The reference images in `ref/` are compared against generated output in `out/`.

- `basic/`: 3 subslides showing progressive Fletcher diagram build-up
- `until/`: 3 subslides where red edge appears then disappears
- `at/`: 3 subslides where yellow node Y appears only on slide 2
- `between/`: 4 subslides where blue edge appears only on slides 2-3
