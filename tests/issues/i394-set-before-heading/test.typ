// Issue: `set text` before a heading creates an empty slide.
// https://github.com/touying-typ/touying/issues/394

#import "/lib.typ": *
#import themes.university: *

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
  config-info(
    title: [Test Title],
    date: none,
    logo: none,
  ),
)

#title-slide()

#set text(size: 18pt)

== Section Title
Test content.
