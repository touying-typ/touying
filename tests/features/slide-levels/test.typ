#import "/lib.typ": *
#import themes.default: *
#import "@preview/numbly:0.1.0": numbly

#show: default-theme.with(
  config-common(slide-level: 3),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

= Slide Levels Configuration Tests

== Level 2 Heading (Not a slide when slide-level is 3)

This is content under a level 2 heading. When slide-level is set to 3, this won't create a new slide.

=== Level 3 Heading (This creates a slide)

This level 3 heading creates a new slide because slide-level is set to 3.

=== Another Level 3 Slide

Each level 3 heading creates a separate slide.

Content for this slide.

== Another Level 2 Section

=== First Slide in Section

Content for the first slide in this section.

=== Second Slide in Section

Content for the second slide in this section.

#show: touying-set-config.with(config-common(slide-level: 2))

== Now Level 2 Creates Slides

After changing slide-level to 2, this level 2 heading creates a new slide.

=== Level 3 is now subsection content

This level 3 heading is now treated as subsection content, not a new slide.

=== More subsection content

More content within the same slide.

== Another Level 2 Slide

This creates another slide since slide-level is now 2.

#show: touying-set-config.with(config-common(slide-level: 1))

= Level 1 Creates Slides Now

With slide-level set to 1, only level 1 headings create new slides.

== This is subsection content

Level 2 and 3 headings are now subsection content.

=== Even deeper subsection

All within the same slide.