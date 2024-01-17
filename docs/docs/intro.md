---
sidebar_position: 1
---

# Introduction to Touying

[Touying](https://github.com/touying-typ/touying) is a slide/presentation package developed for Typst, based on [Polylux](https://github.com/andreasKroepelin/polylux). Touying is similar to LaTeX Beamer but benefits from Typst, providing faster rendering speed and a more concise syntax. Hereafter, we use "slides" to refer to slideshows, "slide" for a single slide, and "subslide" for a sub-slide.

## Why Use Touying

- Unlike PowerPoint, Touying is not a "what you see is what you get" tool. You can write your slides in a "content and style separation" manner, especially with Typst, which offers a concise yet powerful syntax, better supporting content like code blocks, mathematical formulas, and theorems. Another advantage is that, with templates, writing slides with Touying is much faster than PowerPoint. Therefore, Touying is more suitable for users with a demand for "research writing."
- Compared to Markdown Slides, Touying, relying on Typst, has more powerful typesetting control, such as headers, footers, layout, and convenient custom functions. These are capabilities that Markdown struggles to provide, or does not do well. Additionally, Touying offers `#pause` and `#meanwhile` markers, providing more convenient dynamic slide capabilities.
- Compared to Beamer, Touying has faster compilation speed, a more concise syntax, and simpler theme customization capabilities. Touying's compilation speed can be maintained in milliseconds or tens of milliseconds, compared to Beamer's compilation time of seconds or tens of seconds. Touying's syntax is more concise than Beamer, making it easier to change templates and create your own templates. In terms of features, Touying supports most of Beamer's capabilities and provides some convenient features that Beamer lacks.
- Compared to Polylux, Touying provides an object-oriented programming (OOP) style syntax, allowing the simulation of "global variables" through a global singleton. This makes it easy to write themes. Touying does not rely on `counter` and `locate` to implement `#pause`, resulting in better performance. Touying is a community-driven project (we welcome more people to join), and it does not overly emphasize maintaining API consistency. Instead, it chooses to maintain documentation for multiple versions, providing more novel yet powerful features.

## About the Name

"Touying" is derived from the Chinese word "投影" (tóuyǐng), which means "projection" In English, it also conveys the meaning of a "project". In comparison, the term "beamer" in LaTeX means a projector in German.

## About the Documentation

This documentation is powered by [Docusaurus](https://docusaurus.io/). We will maintain English and Chinese versions of the documentation for Touying, and for each major version, we will maintain a documentation copy. This allows you to easily refer to old versions of the Touying documentation and migrate to new versions.

Docusaurus creates a new version:

```sh
npm run docusaurus docs:version 0.y.x
```

## Contribution

Touying is free, open-source, and community-driven. If you're interested, you can visit [GitHub](https://github.com/touying-typ/touying) anytime and raise issues or submit pull requests. We also welcome you to join the [touying-typ](https://github.com/touying-typ) organization.

## License

Touying is released under the [MIT license](https://github.com/touying-typ/touying/blob/main/LICENSE).