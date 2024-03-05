---
sidebar_position: 1
---

# Object-Oriented Programming

Touying provides some convenient utility functions for object-oriented programming.

---

```typst
#let empty-object = (methods: (:))
```
An empty class.

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
Call or display as-is.

---

```typst
#let methods(self) = { .. }
```
Used to bind self to methods and return, very commonly used.