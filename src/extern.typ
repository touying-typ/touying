#import "@preview/uniwarn:0.1.0"
#uniwarn.register-namespace("touying")
#let warning = uniwarn.warning.with(namespace: "touying", prefix: "[touying] ")
#let touying-enable-warnings = uniwarn.enable-warnings.with("touying")
#let touying-disable-warnings = uniwarn.disable-warnings.with("touying")