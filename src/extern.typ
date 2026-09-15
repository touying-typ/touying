// ===========================
//           warnings
// ===========================
#import "@preview/uniwarn:0.1.1"
#uniwarn.register-namespace("touying")
#let warning = uniwarn.warning.with(namespace: "touying", prefix: "[touying] ")
#let touying-enable-warnings = uniwarn.enable-warnings.with("touying")
#let touying-disable-warnings = uniwarn.disable-warnings.with("touying")


// ==================================
//     automatic reducer bindings
// ==================================
#let auto-reducer-bindings = (
  "cetz": (
    "reduce": module => module.canvas,
    "cover": module => module.draw.hide.with(bounds: true),
  ),
  //fletcher does not expose its name, so we detect via repr, see touying-reduce
  "fletcher": (
    "reduce": module => module.diagram,
    "cover": module => module.hide,
  ),
  "alchemist": (
    "reduce": module => module.skeletize,
    "cover": module => module.hide,
  ),
)
