#import "../../../lib.typ": *

#import themes.simple: *

/// Shared content for the two article-mode mark tests, which differ only in
/// `wrap-images`: it picks between article mode's two walks, and only the
/// content-extraction one (`true`) was covered before.
///
/// - wrap (bool): The `wrap-images` setting.
#let render(wrap) = [
  #show: simple-theme.with(
    config-common(export-mode: "article"),
    config-article(wrap-images: wrap),
    config-info(title: [Article Marks], author: [Test Author]),
  )

  == Set Config

  Before the rule.
  #show: appendix
  After the rule. A `touying-set-config` carries the rest of the document as
  its body, so dropping it erased everything from here on.

  == Article Text Written First

  #article-text[
    This prose replaces the whole section, including the content below it.
  ]

  This sentence is written after the article-text and belongs to the same
  section, so it goes too.

  == Article Text Written In The Middle

  Content before. #article-text[Prose, wherever it is written.] Content after.

  == Slide Separators

  ---

  A bare separator breaks slides, so the article drops it.

  #article-only[
    ---

    Inside article-only it is kept: nothing there can break a slide.
  ]

  == Untouched

  This section has no article-text, so it renders normally.
]
