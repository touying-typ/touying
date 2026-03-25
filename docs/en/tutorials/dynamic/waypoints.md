---
sidebar_position: 7
---

# Waypoints

Waypoints let you name positions in your slide's animation timeline and reference them by label instead of hard-coded subslide numbers. This makes animations easier to maintain — inserting a pause or item before a waypoint automatically shifts everything that follows. No more counting the subslides yourself.

## Basic Usage

Place a `#waypoint(<label>)` to mark a named position, then use the label in `#uncover` or `#only`:

```typst
#slide[
  Base content.
  #waypoint(<step-a>)
  #uncover(<step-a>)[Uncovered from step-a.]
  #waypoint(<step-b>)
  #only(<step-b>)[Only during step-b.]
]
```

Each advancing waypoint (the default) creates a new subslide. Here `<step-a>` fires on subslide 2 and `<step-b>` on subslide 3.

## Implicit Waypoints

When you pass a new label directly to `#uncover`, `#only`, or `#item-by-item`, an implicit waypoint is emitted automatically — no separate `#waypoint` call needed:

```typst
#slide[
  First content.
  #uncover(<reveal>)[Appears from here.]
  #only(<final>)[Only on the last step.]
]
```

The implicit waypoint is only registered once per label (the first occurrence wins), so multiple references to the same label share the same position.

## item-by-item with Waypoints

`#item-by-item` accepts a label as its `start` parameter. The items begin revealing from that waypoint's position:

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

This produces 4 subslides: items appear on 2, 3, 4 (the implicit `<list>` waypoint advances to subslide 2), and `<done>` fires on subslide 5. 

> Note: Waypoints capture all subslides into their range until a new waypoint follows.

## Non-advancing Waypoints

By default, waypoints advance the subslide counter. Use `advance: false` on explicit waypoints to mark a position without creating a new subslide:

```typst
#slide[
  #waypoint(<here>, advance: false)
  Content at the current position.
]
```

## Waypoint Markers

For more control, use waypoint markers (`wp-m`) to reference specific parts of a waypoint's range:

| Marker | Meaning |
|---|---|
| `from-wp(<label>)` | All subslides following the first subslide of the waypoint. |
| `until-wp(<label>)` | All subslides until the last subslide of the waypoint's range. |
| `get-first(<label>)` | The first subslide of the waypoint's range. |
| `get-last(<label>)` | The last subslide of the waypoint's range. |
| `prev-wp(<label>)` | The previous waypoint to the given one. |
| `next-wp(<label>)` | The next waypoint to the given one. |
| `not-wp(<label>)`  | All subslides not in the waypoint's range. |

```typst
#slide[
  #waypoint(<mid>)
  #uncover(<mid>)[Visible during mid.]
  #waypoint(<end>)
  #uncover(from-wp(<mid>))[From mid onward.]
  #only(prev-wp(<end>))[Only before end starts.]
]
```

You may even combine waypoint markers to specify the exact behaviour you need:

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


## Complex Example
As previously hinted, waypoints capture the range of subslides following them and you can reuse waypoints later to refer to a whole range.
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

## Explicit Waypoint Starts
You may even set explicit start values for waypoints, both subslide indexes and other waypoints are possible.

```typst
#slide(composer: (1fr, 1fr))[
  #item-by-item(start: <steps>)[
    - Step one
    - Step two
    - Step three
  ]
  #pause
  Some remark.
  #uncover(<done>, start: 4)[All done, even before the remark!]
][
  #waypoint(<parallel>, start: <done>)
  Explaining stuff.
  #pause
  More explanation.
]
```


## More Examples

For a comprehensive set of examples covering all waypoint features — including callback-style slides, integration to CeTZ and Fletcher, `recall-subslide`, and edge cases — see [`examples/waypoints.typ`](https://github.com/touying-typ/touying/blob/main/examples/waypoints.typ).
