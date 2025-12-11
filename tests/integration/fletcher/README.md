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
- `until/`: 3 subslides where red edge appears then disappears
- `at/`: 3 subslides where yellow node Y appears only on slide 2
- `between/`: 4 subslides where blue edge appears only on slides 2-3
