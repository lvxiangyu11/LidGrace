# LidGrace

<p align="center">
  <b>A compact macOS menu bar utility that keeps SSH alive briefly after lid close or lock screen.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-15%2B-lightgrey" alt="macOS 15+" />
  <img src="https://img.shields.io/badge/AppKit-Objective--C-blue" alt="Objective-C" />
  <img src="https://img.shields.io/badge/daemon-zsh-black" alt="zsh daemon" />
  <img src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-red" alt="CC BY-NC-SA 4.0" />
</p>

<p align="center">
  <a href="./README_zh-CN.md">中文说明</a>
</p>

---

## Overview

**LidGrace** is a small macOS menu bar utility for MacBook users who frequently keep remote SSH sessions open.

When you close the lid, lock the screen, or let the display sleep, macOS may quickly enter sleep and drop active SSH connections. LidGrace adds a short grace period before sleep, so brief breaks do not immediately interrupt remote work.

Default behavior:

```text
Lid close / lock screen / display sleep
-> lock the screen
-> keep the system awake for 5 minutes
-> restore normal sleep behavior
-> sleep automatically
```

---

## Use case

LidGrace is designed for short interruptions:

- leaving the desk for a few minutes
- locking the screen while keeping SSH sessions alive
- closing the lid briefly without immediately suspending remote work
- automatically returning to normal sleep after the grace period

---

## Features

- Compact macOS menu bar app.
- Small status bar icon with minimal screen-space usage.
- One-click **Lock Screen Now**.
- Grace period presets: **1 / 3 / 5 / 10 / 30 minutes**.
- Keeps SSH sessions alive during the grace period.
- Locks the screen immediately when triggered.
- Sleeps automatically after the grace period.
- Root LaunchDaemon controls sleep behavior through `pmset`.
- User LaunchAgent runs the menu bar app in the current GUI session.
- Installer cleans older LidGrace builds and launchd entries.
- Diagnostic script included.

---

## Architecture

```text
LidGrace.app
  - menu bar UI
  - lock-screen action in the current GUI session
  - writes user requests and settings

lidgraced
  - root LaunchDaemon
  - detects lid / display / lock state
  - manages pmset disablesleep
  - sleeps the machine after the grace period

Shared state
  - /Library/Application Support/LidGrace
```

The UI app handles actions that must run inside the logged-in user session, such as locking the screen.  
The daemon handles privileged power-management actions, such as temporarily preventing sleep and later allowing sleep again.

---

## Requirements

- macOS 15 or newer
- Apple Silicon MacBook tested
- Xcode Command Line Tools

Install Command Line Tools:

```bash
xcode-select --install
```

---

## Build

```bash
./Scripts/build.sh
```

Build outputs:

```text
Build/LidGrace.app
Build/lidgraced
```

---

## Install

```bash
./Scripts/install.sh
```

The installer performs these steps:

1. Cleans old LidGrace builds and launchd entries.
2. Builds the menu bar app and daemon.
3. Installs `LidGrace.app` into `/Applications`.
4. Installs `lidgraced` into `/usr/local/sbin`.
5. Registers LaunchDaemon and LaunchAgent.
6. Restores `pmset disablesleep 0` before installing the new daemon.

---

## Uninstall

```bash
./Scripts/uninstall.sh
```

---

## Diagnostics

```bash
./Scripts/diagnose.sh
```

The diagnostic script prints:

- launchd status
- `pmset` status
- shared config and status files
- lid/display raw state
- recent logs

---

## Repository layout

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

## License

This project is licensed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License**.

SPDX identifier:

```text
CC-BY-NC-SA-4.0
```

License summary:

- Attribution is required.
- Commercial use is prohibited.
- Modified versions must be shared under the same license.
- Full legal text: <https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode>

For commercial licensing, contact the copyright holder.
