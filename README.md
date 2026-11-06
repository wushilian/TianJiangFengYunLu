# 天降风云录16-10 Android 移植

> 基于 [mkxp-z](https://github.com/mkxp-z/mkxp-z) 的 RPG Maker XP Android 运行壳。

**仓库：** <https://github.com/wushilian/TianJiangFengYunLu>

---

## 简介

这是《天降风云录16-10》的 Android 移植工程，包含：

- Android 启动、解包、存档备份与 `core.zip` 热更新；
- mkxp-z 在 Android 上的全屏、字体、地图和触屏适配；
- 游戏运行所需的兼容脚本与工具；
- 可直接安装的 APK 发布包（见 Releases）。

当前构建：**1.5.29（versionCode 49）**。

> 仓库不包含游戏本体素材、`game.zip`、原生 `.so` 和 APK 源码文件；  
> APK 通过 GitHub Releases 提供，构建所需的二进制见[构建](#构建)。

---

## 截图

| 标题画面 | 游戏画面 |
| --- | --- |
| ![](docs/screenshots/01-title.png) | ![](docs/screenshots/02-world.png) |

| 南疆 | 南疆提示 |
| --- | --- |
| ![](docs/screenshots/03-nanj-town.png) | ![](docs/screenshots/04-nanj-hint.png) |

| 技能菜单 | 战斗技能 |
| --- | --- |
| ![](docs/screenshots/05-skill-menu.png) | ![](docs/screenshots/06-battle-skill.png) |

| 物品列表 | 南疆防具店 |
| --- | --- |
| ![](docs/screenshots/07-item-list.png) | ![](docs/screenshots/08-nanj-armor-shop.png) |

| 真结局 |
| --- |
| ![](docs/screenshots/09-ending.png) |

---

## 目录结构

```text
TianJiangFengYunLu/
├── app/                    Android 应用模块
│   ├── src/main/java/      Android 壳与 mkxp-z 接入
│   ├── src/main/res/       资源与布局
│   ├── src/main/assets/    core.zip（热更新包）
│   └── build.gradle
├── tools/                  构建、安装与数据脚本
├── docs/screenshots/       README 截图
├── gradle/                 Gradle Wrapper
├── gradlew / gradlew.bat
├── settings.gradle
└── README.md
```

需要自行放置、不进入仓库的二进制：

```text
app/src/main/assets/game.zip          RPG Maker XP 游戏数据压缩包
app/src/main/jniLibs/arm64-v8a/*.so   mkxp-z ARM64 原生库
app/src/main/jniLibs/armeabi-v7a/*.so mkxp-z ARMv7 原生库
```

`game.zip` 根目录应包含 `Data/`、`Graphics/`、`Audio/`、`Fonts/`、`mkxp.json` 等游戏文件。

---

## 构建

### 环境

- JDK 17
- Android SDK（compileSdk 36、build-tools 36.0.0）
- 仓库自带 Gradle Wrapper

### 步骤

1. 准备游戏数据，放到：

   ```text
   app/src/main/assets/game.zip
   ```

2. 准备 mkxp-z 原生库，放到：

   ```text
   app/src/main/jniLibs/arm64-v8a/
   app/src/main/jniLibs/armeabi-v7a/
   ```

   需要的库：

   ```text
   libmkxp-z.so
   libruby.so
   libSDL2.so
   libSDL2_image.so
   libSDL2_ttf.so
   libSDL2_sound.so
   libopenal.so
   libc++_shared.so
   ```

3. 写入 `local.properties`：

   ```properties
   sdk.dir=/path/to/android-sdk
   ```

4. 构建：

   ```bash
   ./gradlew clean assembleDebug
   ```

5. 产物：

   ```text
   app/build/outputs/apk/debug/app-debug.apk
   ```

> 仅支持 ARM64 / ARMv7（`arm64-v8a`、`armeabi-v7a`）。

### 生成 game.zip / core.zip

`tools/build_game_zip.py` 会同时生成：

- `app/src/main/assets/game.zip`
- `app/src/main/assets/core.zip`

目录约定：`tianjiang_game` 与本仓库同级。

```text
安卓/
├── TianJiangFengYunLu/
└── tianjiang_game/
```

运行：

```bash
python3 tools/build_game_zip.py
```

---

## core.zip 热更新

- 应用启动时检查 `core.zip`，只刷新小型脚本/数据文件；
- 已解包用户使用 `.ready_v28` 标记，不需要重新解包 60MB；
- 当前 `core.zip` 包含 28 个文件，包括脚本、配置、系统数据和相关地图。

---

## 兼容性

- `applicationId`：`com.tianjiang.fengyun`
- 仅支持 ARM：`arm64-v8a` / `armeabi-v7a`
- 使用原 debug 签名，可覆盖旧测试包；正式分发请自行配置签名
- 更新保留 `Save*.rxdata`，升级前建议手动备份存档
- 需要 Android 6.0（API 23）及以上

---

## 下载

APK 见仓库的 **Releases** 页面：

<https://github.com/wushilian/TianJiangFengYunLu/releases>

---

## 免责声明

本项目仅用于 Android 移植、兼容性研究和学习交流。  
《天降风云录16-10》的游戏数据、图片、音频、字体及其他素材版权归原作者及相应权利方所有。本仓库不包含游戏本体素材、`game.zip`、原生 `.so` 或 APK 源码文件；请使用你合法拥有的游戏数据进行构建。

---

**仓库：** <https://github.com/wushilian/TianJiangFengYunLu>
