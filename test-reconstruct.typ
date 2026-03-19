// Test how reconstruct-styled + show rule behaves
#let typst-builtin-styled = text(red)[].func()

#let reconstruct-styled(it, new-child) = {
  typst-builtin-styled(new-child, it.styles)
}

// We show what kind of content #show: fn produces
#let my-fn(body) = {
  // Just pass through but wrapped
  [WRAPPED: ] + body
}

#let outer-show-rule(body) = {
  // Process content by extracting styled nodes
  let result = ()
  let children = if body.fields().keys().contains("children") {
    body.children
  } else {
    (body,)
  }
  for child in children {
    if child.func() == typst-builtin-styled {
      // It's a styled node - reconstruct with different content
      result.push(reconstruct-styled(child, [INNER CONTENT REPLACED]))
    } else {
      result.push(child)
    }
  }
  result.sum(default: none)
}

#show: outer-show-rule
#show: my-fn
Normal text after my-fn
