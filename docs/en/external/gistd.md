---
sidebar_position: 2
---

# Gistd

[Gistd](https://github.com/Myriad-Dreamin/gistd) instantly share [typst](https://typst.app) documents on git and other network storage. The most important feature is that it based on typst.ts to compile typst document, you can select and copy text!

- [Global (Cloudflare CDN)](https://gistd.myriad-dreamin.com)
- [Asia Region (Mirror, 亚洲区域镜像)](https://gistd-cn.myriad-dreamin.com)

## Loading a document on GitHub

Assuming that you have a GitHub link, for example:

```
https://github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

Simply replace the `github.com` with `gistd.myriad-dreamin.com`:

```
https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

Example Documents:

- [https://gistd.myriad-dreamin.com/johanvx/typst-undergradmath/blob/main/undergradmath.typ](https://gistd.myriad-dreamin.com/johanvx/typst-undergradmath/blob/main/undergradmath.typ)
- [https://gistd.myriad-dreamin.com/Jollywatt/typst-fletcher/blob/main/docs/manual.typ](https://gistd.myriad-dreamin.com/Jollywatt/typst-fletcher/blob/main/docs/manual.typ)
- [https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ](https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ)

## View Parameters

These URL parameters can change the behavior of gistd.

- `g-page`: The page number to display. Default is `1`. Only available in the slide mode.
- `g-mode`: The mode to display.
  - `doc`: View the document in the document mode.
  - `slide`: View the document in the slide mode.
- `g-version`: The typst compiler version to use.
  - Could be `v0.13.0`, `v0.13.1`, `v0.14.0`, or `latest`.

## Slide View

Using `g-mode=slide` mentioned above to view the document in the slide mode:

Example Documents:

- [A simple touying side.](https://gistd.myriad-dreamin.com/touying-typ/touying/blob/main/examples/simple.typ?g-mode=slide)

## Loading a document by arbitrary links

Assuming that you have arbitrary link, for example:

```
https://github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

Put `any-gistd.myriad-dreamin.com` before the link:

```
https://any-gistd.myriad-dreamin.com/github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

`any-gistd.myriad-dreamin.com` is alias for `gistd.myriad-dreamin.com/@any`.

If a domain (host) is specially identified, gistd will use corresponding approach to serve the document.

- `github.com`: git protocol.
- `codeberg.org`: git protocol.
- `localhost` and others: HTTP protocol if host is `localhost` otherwise https protocol. Note: gistd won't load other files on the specified domain if it cannot identifies the domain, i.e. the typst document cannot load other resources relative to the domain.

Example Documents:

- [https://any-gistd.myriad-dreamin.com/github.com/Myriad-Dreamin/gistd/raw/main/README.typ](https://any-gistd.myriad-dreamin.com/github.com/Myriad-Dreamin/gistd/raw/main/README.typ)
- [https://gistd.myriad-dreamin.com/@any/github.com/Myriad-Dreamin/gistd/raw/main/README.typ](https://gistd.myriad-dreamin.com/@any/github.com/Myriad-Dreamin/gistd/raw/main/README.typ)

## Loading a document without cors proxy

By default, gistd uses a trusted cors proxy (`https://underleaf.mgt.workers.dev`) to load documents. This is because GitHub and Forgejo doesn't allow gistd to load documents. See [isomorphic-git: Quickstart](https://isomorphic-git.org/docs/en/quickstart) for more details.

However, you may want to load a document without cors proxy. You can do this by adding `g-cors=false` to the query string.

For example, to load a document at `http://localhost:11449/main.typ`:

- [https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false](https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false)

## Loading a document with HTTP protocol

`@any` infers protocol from the URL, while you could use `@http` to force HTTP protocol. For example, to load a document at `http://localhost:11449/main.typ`:

- [https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false](https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false)

### Development

Install dependencies:

```
pnpm install
```

Develop locally:

```
pnpm dev
```

Build:

```
pnpm build
```
