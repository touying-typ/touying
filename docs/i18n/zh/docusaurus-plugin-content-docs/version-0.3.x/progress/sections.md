---
sidebar_position: 2
---

# Touying 的 Sections

Touying 维护了一份自己的 sections state，用于记录 slides 的 sections 和 subsections。

## touying-outline

`#touying-outline(enum-args: (:), padding: 0pt)` 用于显示一个简单的大纲。


## touying-final-sections

`#states.touying-final-sections(final-sections => ..)` 用于自定义显示大纲。


## touying-progress-with-sections

```typst
#states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)
```

功能最强大，你可以用其搭建任意复杂的进度展示。
