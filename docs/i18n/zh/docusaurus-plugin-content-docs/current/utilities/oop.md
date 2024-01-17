---
sidebar_position: 1
---

# 面向对象编程

Touying 提供了一些便利的工具函数，便于进行面向对象编程。

---

```typst
#let empty-object = (methods: (:))
```
一个空类。

---

```typst
#let call-or-display(self, it) = {
  if type(it) == function {
    return it(self)
  } else {
    return it
  }
}
```
调用或原样输出。

---

```typst
#let methods(self) = { .. }
```
用于为方法绑定 self 并返回，十分常用。

