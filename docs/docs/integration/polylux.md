---
sidebar_position: 6
---

# Polylux

With the compatibility between Touying and Polylux, you can make Polylux support direct export as well. Just add the following code to your Polylux source code:

```typst
#import "@preview/touying:0.3.1"

#locate(loc => touying.pdfpc.pdfpc-file(loc))
```

Assuming your document is `./example.typ`, you can then export the `.pdfpc` file directly using the following command:

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

This eliminates the need for an additional `polylux2pdfpc` program.