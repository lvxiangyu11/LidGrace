# LidGrace

<p align="center">
  <b>一个 macOS 菜单栏小工具：合盖 / 锁屏后保活几分钟，再自动休眠。</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-15%2B-lightgrey" alt="macOS 15+" />
  <img src="https://img.shields.io/badge/AppKit-Objective--C-blue" alt="Objective-C" />
  <img src="https://img.shields.io/badge/daemon-zsh-black" alt="zsh daemon" />
  <img src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-red" alt="CC BY-NC-SA 4.0" />
</p>

<p align="center">
  <a href="./README.md">English README</a>
</p>

---

## 简介

**LidGrace** 是一个面向 MacBook 的菜单栏工具，用来处理合盖 / 锁屏 / 熄屏后 SSH 连接很快断开的场景。

当你临时离开电脑几分钟时，LidGrace 会让系统保持醒着一小段时间，SSH 会话继续保持。倒计时结束后，系统恢复正常睡眠行为并自动休眠。

默认行为：

```text
合盖 / 锁屏 / 熄屏
-> 立即锁屏
-> 系统保持醒着 5 分钟
-> 恢复正常睡眠行为
-> 自动休眠
```

---

## 使用场景

LidGrace 适合这些短暂离开场景：

- 离开座位几分钟
- 锁屏后继续保持 SSH 会话
- 短暂合盖后继续保留远程连接
- 保活时间结束后自动回到正常休眠

---

## 功能

- macOS 菜单栏小工具。
- 小图标显示，占用菜单栏空间很少。
- 菜单栏一键 **Lock Screen Now**。
- 可选保活时间：**1 / 3 / 5 / 10 / 30 分钟**。
- 保活期间 SSH 连接继续保持。
- 触发后立即锁屏。
- 倒计时结束后自动休眠。
- root LaunchDaemon 通过 `pmset` 控制睡眠行为。
- 当前用户 LaunchAgent 在图形会话中运行菜单栏 App。
- 安装前自动清理旧版本 LidGrace 残留。
- 自带诊断脚本。

---

## 架构

```text
LidGrace.app
  - 菜单栏 UI
  - 当前用户图形会话里的锁屏动作
  - 写入用户请求和配置

lidgraced
  - root LaunchDaemon
  - 检测合盖 / 熄屏 / 锁屏状态
  - 控制 pmset disablesleep
  - 倒计时结束后执行系统休眠

共享状态目录
  - /Library/Application Support/LidGrace
```

设计分工：

| 组件 | 职责 |
|---|---|
| `LidGrace.app` | UI、菜单、锁屏、配置修改 |
| `lidgraced` | 合盖检测、睡眠控制、倒计时 |
| 共享状态目录 | App 和 daemon 之间交换状态 |

---

## 系统要求

- macOS 15 或更新版本
- Apple Silicon MacBook 已测试
- Xcode Command Line Tools

安装 Command Line Tools：

```bash
xcode-select --install
```

---

## 构建

```bash
./Scripts/build.sh
```

输出：

```text
Build/LidGrace.app
Build/lidgraced
```

---

## 安装

```bash
./Scripts/install.sh
```

安装脚本会执行：

1. 清理旧版本 LidGrace 残留。
2. 构建菜单栏 App 和 daemon。
3. 安装 `LidGrace.app` 到 `/Applications`。
4. 安装 `lidgraced` 到 `/usr/local/sbin`。
5. 注册 LaunchDaemon 和 LaunchAgent。
6. 安装前恢复 `pmset disablesleep 0`。

---

## 卸载

```bash
./Scripts/uninstall.sh
```

---

## 诊断

```bash
./Scripts/diagnose.sh
```

诊断内容包括：

- launchd 状态
- `pmset` 状态
- 配置文件和状态文件
- 合盖 / 熄屏原始状态
- 最近日志

---

## 目录结构

```text
LidGrace/
├── README.md
├── README_zh-CN.md
├── LICENSE
├── Scripts/
│   ├── build.sh
│   ├── install.sh
│   ├── uninstall.sh
│   ├── clean_all_old.sh
│   └── diagnose.sh
└── Sources/
    ├── LidGraceApp/
    └── LidGraceDaemon/
```

---

## 许可证

本项目使用 **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License**。

SPDX 标识：

```text
CC-BY-NC-SA-4.0
```

许可证概要：

- 使用时需要署名。
- 商业使用受限。
- 修改版需要使用相同许可证发布。
- 完整法律文本：<https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode>

商业授权请联系版权持有人。
