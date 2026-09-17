// Math elements whose content lives outside the usual `body`/`children`
// fields must be traversed and rebuilt, or animation marks inside them leak
// through to the final document and fail with "Unsupported mark".

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== Delimiter annotations

$ underparen(x, pause y) $
$ overparen(x, pause y) $
$ undershell(x, pause y) $
$ overshell(x, pause y) $

== Other content-bearing math elements

$ #math.stretch([#pause $x$], size: 2em) $
$ #math.op([#pause $x$]) $
