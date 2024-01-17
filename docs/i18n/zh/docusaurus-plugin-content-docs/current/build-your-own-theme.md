---
sidebar_position: 7
---

# 创建自己的主题

您可以参考 [主题的源代码](https://github.com/touying-typ/touying/tree/main/themes)，主要需要实现的就是：

- 自定义颜色主题，即修改 `self.colors`。
- 自定义 header；
- 自定义 footer;
- 自定义 `alert` 函数，可选；
- 自定义 `slide` 函数；
- 自定义特殊 slide 函数，如 `title-slide` 和 `focus-slide` 函数；
- 自定义 `slide-in-slides` 函数，该函数会被 `slides` 函数调用；
- 自定义 `slides` 函数，可选；
- 自定义 `register` 函数，初始化全局单例 `s`；
- 自定义 `init` 函数，可选。

待补充更详细的文档。
