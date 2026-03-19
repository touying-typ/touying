// Minimal test: does invisible content between pages create extra pages?
#set page(width: 200pt, height: 100pt)

Page 1
#pagebreak()

// Just invisible counter update between pages
#counter("test").update(0)

Page 2
