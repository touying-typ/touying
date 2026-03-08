// Test: does a box(0,0) in the middle set page create a blank page?
#set page(width: 200pt, height: 100pt)

Page 1 content

#set page(width: 200pt, height: 100pt, fill: none)
// Only a zero-size box - does this create page 2?
#box(width: 0pt, height: 0pt)

#set page(width: 200pt, height: 100pt, fill: none)
Page 3 content
