---
sidebar_position: 1
---

# 简单动画

Touying 为简单的动画效果提供了两个标记：`#pause` 和 `#meanwhile`。

## pause

`#pause` 的用途很简单，就是用于将后续的内容放到下一张 subslide 中，并且可以使用多个 `#pause` 以创建多张 subslides，一个简单的例子：

```typst
#slide[
  First #pause Second

  #pause

  Third
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/a3bed1d3-e660-456d-8a54-a914436f43bf)

这个例子将会创建三张 subslides，逐渐地将内容展示出来。

如你所见，`#pause` 既可以放在行内，也可以放在单独的一行。


## meanwhile

有些情况下，我们需要在 `#pause` 的同时展示一些其他内容，这时候我们就可以用 `#meanwhile`。

```typst
#slide[
  First
  
  #pause
  
  Second

  #meanwhile

  Third

  #pause

  Fourth
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/24ca19a3-b27c-4d31-ab75-09c37911e6ac)

这个例子只会创建两张 subslides，并且 "First" 和 "Third" 同时显示，"Second" 和 "Fourth" 同时显示。


## 如何处理 set-show rules?

如果你在 `slide[..]` 里面使用了 set-show rules，你会惊讶的发现，在那之后的 `#pause` 和 `#meanwhile` 都失效了。这是因为 Touying 无法探知 `styled(..)` 内部的内容（set-show rules 后的内容会被 `styled` 囊括起来）。

为了解决这个问题，Touying 为 `#slide()` 函数提供了一个 `setting` 参数，你可以将你的 set-show rules 放到 `setting` 参数里，例如修改字体颜色：

```typst
#slide(setting: body => {
  set text(fill: blue)
  body
})[
  First
  
  #pause
  
  Second
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/8e31fc8a-5ab1-4181-a46a-fa96cf790dff)


同理，Touying 目前也不支持 `grid` 这类 layout 函数内部的 `#pause` 和 `#meanwhile`，也是由于同样的限制，但是你可以使用 `#slide()` 的 `composer` 参数，大部分情况下都应该能满足需求。


:::tip[原理]

Touying 不依赖 `counter` 和 `locate` 来实现 `#pause`，而是用 Typst 脚本写了一个 parser。它会将输入内容块作为 sequence 解析，然后改造重组这个 sequence 为我们需要的一系列 subslides。

:::