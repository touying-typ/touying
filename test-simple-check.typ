#let typst-builtin-styled = text(red)[].func()

// Does reconstructing a styled node actually re-apply the show rule?
#let outer(body) = {
  // Find styled node from #show: inner and re-wrap it  
  let content = body
  [Result: #body]  // Just show the body
}

#show: outer
#show: text.with(fill: blue)
This text should be blue if set-rule is applied
