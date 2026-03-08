---
sidebar_position: 4
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) 是一个命令行工具，可将 Touying 演示文稿导出为视频格式（MP4、GIF、WebM），方法是渲染每个子幻灯片并将其组合为动画。

## 安装

```sh
cargo install touying-exporter
```

或从[发布页面](https://github.com/touying-typ/touying-exporter/releases)下载预编译的二进制文件。

## 基本用法

对于一个 Touying `.typ` 文件，运行：

```sh
touying-exporter slides.typ --output slides.mp4
```

此命令会编译演示文稿的每一页（子幻灯片）并以默认帧率将其编码为视频。

### 常用选项

| 参数 | 说明 |
|------|------|
| `--output <PATH>` | 输出文件路径。格式由文件扩展名推断（`.mp4`、`.gif`、`.webm`）。 |
| `--fps <N>` | 导出视频的帧率（默认：`24`）。 |
| `--duration <SECS>` | 每张幻灯片在切换前的停留时长，单位为秒（默认：`1`）。 |
| `--root <PATH>` | Typst 编译器的根路径，等价于 `typst compile --root`。 |
| `--font-path <PATH>` | 额外的字体搜索路径。 |

### 示例：导出为 GIF

```sh
touying-exporter slides.typ --output slides.gif --fps 2 --duration 2
```

此命令生成一个每 2 秒切换一个子幻灯片、帧率为 2fps 的 GIF，适合嵌入到网站或 README 文件中作为动态演示。

### 示例：导出为 MP4

```sh
touying-exporter slides.typ --output slides.mp4 --fps 30 --duration 3
```

## 提示

- **讲义模式** — 导出前，请考虑是否需要完整的动画版本或静态讲义。如需静态导出，在文档中传入 `config-common(handout: true)`。
- **字体路径** — 如果系统字体未被自动检测到，请添加 `--font-path /path/to/fonts`。
- **CI/自动化** — `touying-exporter` 可集成到 CI 流水线中，自动为幻灯片仓库生成演示 GIF。
