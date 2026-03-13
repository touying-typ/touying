---
sidebar_position: 7
---

# 路标

路标允许你为幻灯片动画时间线中的位置命名，并通过标签引用它们，而不是使用硬编码的 subslide 编号。这使得动画更容易维护——在路标之前插入 pause 或新项目时，后续内容会自动调整位置。再也不需要自己数 subslide 了。

## 基本用法

使用 `#waypoint(<label>)` 标记一个命名位置，然后在 `#uncover` 或 `#only` 中使用该标签：

```typst
#slide[
  Base content.
  #waypoint(<step-a>)
  #uncover(<step-a>)[Uncovered from step-a.]
  #waypoint(<step-b>)
  #only(<step-b>)[Only during step-b.]
]
```

每个前向路标（默认行为）会创建一个新的 subslide。这里 `<step-a>` 在 subslide 2 触发，`<step-b>` 在 subslide 3 触发。

## 隐式路标

当你直接将一个新标签传递给 `#uncover`、`#only` 或 `#item-by-item` 时，会自动生成一个隐式路标——无需单独调用 `#waypoint`：

```typst
#slide[
  First content.
  #uncover(<reveal>)[Appears from here.]
  #only(<final>)[Only on the last step.]
]
```

每个标签的隐式路标只会注册一次（首次出现生效），因此对同一标签的多次引用共享同一位置。

## item-by-item 与路标

`#item-by-item` 接受标签作为其 `start` 参数。项目从该路标的位置开始逐个显示：

```typst
#slide[
  #item-by-item(start: <list>)[
    - Alpha
    - Beta
    - Gamma
  ]
  #only(<done>)[All items revealed.]
]
```

这将产生 4 个 subslides：项目分别出现在 2、3、4（隐式 `<list>` 路标前进到 subslide 2），`<done>` 在 subslide 5 触发。

注意：路标会捕获其后的所有 subslides 直到下一个路标出现。

## 非前向路标

默认情况下，路标会推进 subslide 计数器。使用 `advance: false` 可以标记位置而不创建新的 subslide：

```typst
#slide[
  #waypoint(<here>, advance: false)
  Content at the current position.
]
```

## 路标标记

如需更精细的控制，可以使用路标标记（`wp-m`）来引用路标范围的特定部分：

| 标记 | 含义 |
|---|---|
| `from-wp(<label>)` | 从路标的第一个 subslide 之后的所有 subslides。|
| `until-wp(<label>)` | 直到路标范围最后一个 subslide 的所有 subslides。|
| `get-first(<label>)` | 路标范围的第一个 subslide。|
| `get-last(<label>)` | 路标范围的最后一个 subslide。|
| `prev-wp(<label>)` | 给定路标的前一个路标。|
| `next-wp(<label>)` | 给定路标的后一个路标。|
| `not-wp(<label>)` | 不在路标范围内的所有 subslides。|

```typst
#slide[
  #waypoint(<mid>)
  #uncover(<mid>)[Visible during mid.]
  #waypoint(<end>)
  #uncover(from-wp(<mid>))[From mid onward.]
  #only(prev-wp(<end>))[Only before end starts.]
]
```

你甚至可以组合使用路标标记来指定确切的行为：

```typst
#slide[
  #waypoint(<mid>, advance:false)
  #uncover(<mid>)[Visible during mid.]
  #pause
  Second mid.
  #waypoint(<end>)
  End.

  #only(not-wp(get-first(<mid>)))[Soon finished.]
]
```

## 综合示例

如前所述，路标可以捕获其后的一系列 subslides，你也可以在之后引用整个范围。

```typst
#slide(composer: (1fr, 1fr))[
  #item-by-item(start: <steps>)[
    - Step one
    - Step two
    - Step three
  ]
  #pause
  Some remark.
  #uncover(<done>)[All done!]
][
  #alternatives(at: (<steps>, <done>))[
    _Working through the steps..._
  ][
    _Complete!_
  ]
]
```

## 更多示例

有关路标功能的完整示例——包括回调风格的幻灯片、与 CeTZ 和 Fletcher 的集成、`recall-subslide` 以及边界情况——请参阅 [`examples/waypoints.typ`](https://github.com/touying-typ/touying/blob/main/examples/waypoints.typ)。
