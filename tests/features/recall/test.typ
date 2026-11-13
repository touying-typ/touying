#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Recall & Reference Tests

== First Topic <first-topic>

This is the first topic that we'll reference later.

Key points:
- Important concept A
- Important concept B
- Important concept C

== Second Topic <second-topic>

This slide introduces another concept.

Content about the second topic goes here.

== Third Topic

Now we can recall previous topics using the recall function.

#touying-recall(<first-topic>)

== Another Reference Example

We can also recall the second topic:

#touying-recall(<second-topic>)<second-topic-again>

== Multiple Recalls

Sometimes we need to reference multiple previous slides:

First, let's recall the first topic:
#touying-recall(<first-topic>)

Then, let's recall the second topic:
#touying-recall(<second-topic>)

== Cross-references in Content

You can also reference slides inline like in your text content.

// A recalled slide emits its labels again, so a copy names them with a number,
// or with the label written after the call.
#context {
  let count(name) = query(label(name)).len()
  for name in (
    "first-topic",
    "first-topic-1",
    "first-topic-2",
    "second-topic",
    "second-topic-again",
    "second-topic-1",
  ) {
    assert.eq(count(name), 1, message: "label `" + name + "` has to occur once")
  }
}
