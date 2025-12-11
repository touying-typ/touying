# Fletcher Integration Tests

This directory contains visual regression tests for Touying's Fletcher diagram integration, including tests for conditional rendering functions (`until`, `at`, `between`).

## Test Structure

- `basic/` - Basic Fletcher animation with `pause`
- `until/` - Reverse reveal using `until(n)` to hide content after slide n
- `at/` - Show content only at specific slide using `at(n)`
- `between/` - Show content in a range using `between(start, end)`

## Test Expectations

Each test generates multiple pages (subslides). The reference images in `ref/` are compared against generated output in `out/`.

- `basic/`: 3 subslides showing progressive Fletcher diagram build-up
- `until/`: 4 subslides (red edge visible 1-2, green edge appears at 3)
- `at/`: 4 subslides (yellow node Y only on slide 2, Z appears at slide 3)
- `between/`: 5 subslides (blue edge visible on slides 2-3, End node at slide 4)
