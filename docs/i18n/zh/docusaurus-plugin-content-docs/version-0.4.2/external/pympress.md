---
sidebar_position: 2
---

# Pympress

[Pympress](https://github.com/Cimbali/pympress) 是一种 PDF 演示工具，专为演示文稿和公开演讲等双屏设置而设计。高度可配置、功能齐全且可移植。


## 笔记支持

```typst
#import "@preview/touying:0.4.2": *

#let s = themes.university.register(aspect-ratio: "16-9")

// Set the speaker notes configuration, you can show it by pympress
#let s = (s.methods.show-notes-on-second-screen)(self: s, right)

#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Animation

== Simple Animation

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `#let s = (s.math.show-notes-on-second-screen)(self: s, right)`
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/b43c7f99-c5f9-4084-aa70-c1561e8aafee)

然后我们就可以使用 pympress 放映了。

![image](https://github.com/touying-typ/touying/assets/34951714/afbe17cb-46d4-4507-90e8-959c53de95d5)

