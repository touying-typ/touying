// Test whether reconstruct-styled actually re-applies the show rule
#let call-count = counter("calls")

#let my-fn(body) = {
  call-count.step()
  body  // pass-through
}

#let typst-builtin-styled = text(red)[].func()

#let outer(body) = {
  // Process body: find styled nodes and reconstruct them
  if body.func() == typst-builtin-styled {
    // This is the styled(my-fn, "inner content") node
    // Reconstruct it - does this call my-fn again?
    typst-builtin-styled([REPLACED BY OUTER], body.styles)
  } else {
    body
  }
}

#show: outer
#show: my-fn
Inner content
