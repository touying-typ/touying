// ===========================
//           warnings
// ===========================
#import "@preview/uniwarn:0.1.1"
#uniwarn.register-namespace("touying")
#let warning = uniwarn.warning.with(namespace: "touying", prefix: "[touying] ")

/// Turn off the warnings that touying emits, from this point of the document on.
/// Touying uses [uniwarn](https://typst.app/universe/package/uniwarn) with the
/// namespace `touying`. The call returns content and has to be placed in the
/// document, so write `#touying-disable-warnings()` with the parentheses.
///
/// Example:
///
/// ```typ
/// #touying-disable-warnings()
/// ```
///
/// -> content
#let touying-disable-warnings() = uniwarn.disable-warnings("touying")

/// Turn the warnings that touying emits back on after
/// `touying-disable-warnings()`. They are on by default.
///
/// Example:
///
/// ```typ
/// #touying-enable-warnings()
/// ```
///
/// -> content
#let touying-enable-warnings() = uniwarn.enable-warnings("touying")


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
  // all other packages should expose the dict
  // `let touying-reducer-bindings = ("reduce": module => module.REDUCTION_FUNCTION, "cover": module => module.HIDE_FUNCTION)`
  // where your reduction function would be the function that users write input to
  // and the hide function should preserve the content dimensions
  // if something is deeper inside your package look at the way it is done for cetz where "cover": module => module.draw.hide.with(bounds:true)
)
