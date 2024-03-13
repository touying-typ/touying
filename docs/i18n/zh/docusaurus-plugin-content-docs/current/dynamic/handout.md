---
sidebar_position: 6
---

# 创建讲义

在看幻灯片、听课的同时，听众往往会希望有一个讲义，以便能够回顾理解困难的地方，所以，作者最好能给听众提供这样一份讲义，如果能在听课前提供更好。

讲义模式与普通模式的区别是，其不需要过于繁杂的动画效果，因此只会保留每个 slide 的最后一张 subslide。

开启讲义模式是很简单的：

```typst
#let store = (store.methods.enable-handout-mode)(self: store)
```
