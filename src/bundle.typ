// Helpers for Typst's (experimental) bundle export, where one compilation emits
// several `#document`s at once.

/// Locate the `document` element that `loc` lives in.
///
/// Introspection in a bundle export observes the whole bundle instead of a
/// single document, so a plain `query(..)` inside one `#document` also returns
/// the matches of every other document in the bundle (see #406 and #408). The
/// only handle on "my own document" is the last `document` element that starts
/// before us, a trick taken from this forum post:
/// https://forum.typst.app/t/how-to-query-headings-in-current-document/9308
///
/// In an ordinary (non-bundle) export there is no `document` element at all, so
/// this returns `none` and callers have to fall back to unrestricted queries.
///
/// - loc (location): A location inside the document of interest, e.g. `here()`.
///
/// -> location, none
#let current-document-location(loc) = {
  let current-and-prev-documents = query(selector(document).before(loc))
  if current-and-prev-documents.len() > 0 {
    current-and-prev-documents.last().location()
  }
}

/// Restrict a selector to the document that `loc` lives in.
///
/// Returns `target-selector` unrestricted outside of bundle export, because
/// `within(document)` has no meaning there.
///
/// - target-selector (selector, label, function): The selector to restrict.
///
/// - loc (location): A location inside the document of interest, e.g. `here()`.
///
/// -> selector
#let within-current-document(target-selector, loc) = {
  let document-location = current-document-location(loc)
  if document-location == none {
    selector(target-selector)
  } else {
    selector(target-selector).within(document-location)
  }
}
