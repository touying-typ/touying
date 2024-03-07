---
sidebar_position: 6
---

# Polylux

借助 Touying 与 Polylux 的兼容性，你可以让 Polylux 也支持直接导出，只需要在你的 Polylux 源代码中加入下面的代码即可。

```
#import "@preview/touying:0.3.1"

#locate(loc => touying.pdfpc.pdfpc-file(loc))
```

假设你的文档为 `./example.typ`，则你可以通过

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

直接导出 `.pdfpc` 文件，而不需要使用额外的 `polylux2pdfpc` 程序。