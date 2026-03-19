// Test how #show: fn interacts with reconstruct-styled
#let typst-builtin-styled = text(red)[].func()

#let my-fn(body) = [WRAPPED-BY-FN]  // Note: body is discarded

// Test 1: Does show rule actually transform content?
#show: my-fn  // Should apply my-fn to everything below
Hello World
