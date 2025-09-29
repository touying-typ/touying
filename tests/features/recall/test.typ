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

#touying-recall(<second-topic>)

== Multiple Recalls

Sometimes we need to reference multiple previous slides:

First, let's recall the first topic:
#touying-recall(<first-topic>)

Then, let's recall the second topic:
#touying-recall(<second-topic>)

== Cross-references in Content

You can also reference slides inline like in your text content.
