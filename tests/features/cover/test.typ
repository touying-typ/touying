#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Cover & Overlay Tests

== Semi-transparent Cover

Regular content here.

#show: touying-set-config.with(config-methods(cover: utils.semi-transparent-cover))

#pause

This content appears with semi-transparent cover effect.

#pause

More content with the same effect.

== Opaque Cover

#show: touying-set-config.with(config-methods(cover: utils.opaque-cover))

First item.

#pause

Second item appears while first is covered with opaque effect.

== Default Cover Behavior

#show: touying-set-config.with(config-methods(cover: utils.hide))

Content that gets hidden completely when covered.

#pause

New content replaces the old content entirely.