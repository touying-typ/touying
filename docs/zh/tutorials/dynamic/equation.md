---
sidebar_position: 3
---

# 数学公式动画

数学公式和其他内容一样可以做动画：直接在 `$ .. $` 里写 `#pause`、`#meanwhile`、`#only`、`#uncover` 或 `#alternatives` 即可。在数学模式下，不带 `#` 的 `pause` 同样有效。

## 简单动画

让我们先来看一个例子：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Touying equation with pause:

  $
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  $

  #meanwhile

  Touying equation is very simple.
]
```


正如你料想的一样，数学公式会分步显示，这很适合给让演讲者演示自己的数学公式推理思路。


## 复杂动画

`only`、`uncover`、`effect` 和 `alternatives` 在公式内部同样可用：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  $
    f(x) &= #pause x^2 + 2x + #uncover("3-")[1]  \
         &= #pause (x + 1)^2  \
  $
]
```

## 在 `frac`、`mat` 等数学元素内部

动画同样可以进入那些把内容存放在自己字段里的数学元素，例如 `frac`、`mat`、
`vec`、`cases`、`binom`、`root`、`attach`、`accent` 以及各类括号函数：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  $ frac(a #pause + b, c) $

  $ mat(a, #pause b; c, d) $

  $ a^(2 #pause + 1) $
]
```

唯一的例外是重音符号的 *accent* 参数（`accent(x, hat)` 中的 `hat`）：Typst 把它存
为单个符号而非内容，因此无法就地做动画。请改为整体替换该元素：

```typst
#alternatives($accent(x, hat)$, $accent(x, tilde)$)
```

## 引用带动画的内容

Typst 只允许对少数几类元素写 `@label`——figure、equation、heading 和 footnote。其他一切都必须包在 figure 里。因此，如果要引用一个带动画的代码块或者 reducer 图形，请把它包起来：

```typst
#figure(
  touying-raw(```py
x = 1
# pause
y = 2
```),
)<my-code>

See @my-code.
```

figure 同时还会给你一个 caption 和一个 `kind`。如果直接把 label 挂在 raw 代码块上，`#link(<my-code>)[jump there]` 依然可以正常工作，这种用法不需要 figure。

带动画的内容上的 label 不应该在每张子幻灯片上都重复出现。`config-common(label-only-on-last-subslide: ..)` 控制哪些元素函数的 label 会被去重。