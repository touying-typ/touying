---
sidebar_position: 2
---

# [Gistd](https://github.com/Myriad-Dreamin/gistd)

即时分享 [typst](https://typst.app) 文档到 Git 和其他网络存储。最重要的特性是它基于 typst.ts 来编译 typst 文档，你可以选择并复制文本！

- [全球节点 (Cloudflare CDN)](https://gistd.myriad-dreamin.com)
- [亚洲区域 (镜像)](https://gistd-cn.myriad-dreamin.com)

## 加载 GitHub 上的文档

假设你有一个 GitHub 链接，例如：

```
https://github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

只需将 `github.com` 替换为 `gistd.myriad-dreamin.com`：

```
https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

示例文档：

- [https://gistd.myriad-dreamin.com/johanvx/typst-undergradmath/blob/main/undergradmath.typ](https://gistd.myriad-dreamin.com/johanvx/typst-undergradmath/blob/main/undergradmath.typ)
- [https://gistd.myriad-dreamin.com/Jollywatt/typst-fletcher/blob/main/docs/manual.typ](https://gistd.myriad-dreamin.com/Jollywatt/typst-fletcher/blob/main/docs/manual.typ)
- [https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ](https://gistd.myriad-dreamin.com/typst/templates/blob/main/charged-ieee/template/main.typ)

## 查看参数

这些 URL 参数可以改变 gistd 的行为。

- `g-page`: 要显示的页码。默认为 `1`。仅在幻灯片模式下可用。
- `g-mode`: 显示模式。
  - `doc`: 以文档模式查看文档。
  - `slide`: 以幻灯片模式查看文档。
- `g-version`: 要使用的 typst 编译器版本。
  - 可以是 `v0.13.0`、`v0.13.1`、`v0.14.0` 或 `latest`。

## 幻灯片视图

使用上面提到的 `g-mode=slide` 以幻灯片模式查看文档：

示例文档：

- [一个简单的 touying 幻灯片](https://gistd.myriad-dreamin.com/touying-typ/touying/blob/main/examples/simple.typ?g-mode=slide)

## 通过任意链接加载文档

假设你有一个任意链接，例如：

```
https://github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

在链接前添加 `any-gistd.myriad-dreamin.com`：

```
https://any-gistd.myriad-dreamin.com/github.com/typst/templates/blob/main/charged-ieee/template/main.typ
```

`any-gistd.myriad-dreamin.com` 是 `gistd.myriad-dreamin.com/@any` 的别名。

如果某个域名（主机）被特别识别，gistd 将使用相应的方式来提供文档。

- `github.com`: git 协议。
- `codeberg.org`: git 协议。
- `localhost` 和其他: 如果主机是 `localhost` 则使用 HTTP 协议，否则使用 https 协议。注意：如果 gistd 无法识别该域名，则不会加载该域名上的其他文件，即 typst 文档无法加载相对于该域名的其他资源。

示例文档：

- [https://any-gistd.myriad-dreamin.com/github.com/Myriad-Dreamin/gistd/raw/main/README.typ](https://any-gistd.myriad-dreamin.com/github.com/Myriad-Dreamin/gistd/raw/main/README.typ)
- [https://gistd.myriad-dreamin.com/@any/github.com/Myriad-Dreamin/gistd/raw/main/README.typ](https://gistd.myriad-dreamin.com/@any/github.com/Myriad-Dreamin/gistd/raw/main/README.typ)

## 不使用 CORS 代理加载文档

默认情况下，gistd 使用一个受信任的 CORS 代理（`https://underleaf.mgt.workers.dev`）来加载文档。这是因为 GitHub 和 Forgejo 不允许 gistd 直接加载文档。更多详情请参见 [isomorphic-git: 快速入门](https://isomorphic-git.org/docs/en/quickstart)。

然而，你可能希望不使用 CORS 代理来加载文档。你可以通过在查询字符串中添加 `g-cors=false` 来实现。

例如，要加载 `http://localhost:11449/main.typ` 处的文档：

- [https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false](https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false)

## 使用 HTTP 协议加载文档

`@any` 从 URL 推断协议，而你可以使用 `@http` 来强制使用 HTTP 协议。例如，要加载 `http://localhost:11449/main.typ` 处的文档：

- [https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false](https://gistd.myriad-dreamin.com/@http/localhost:11449/main.typ?g-cors=false)

### 开发

安装依赖：

```
pnpm install
```

本地开发：

```
pnpm dev
```

构建：

```
pnpm build
```
