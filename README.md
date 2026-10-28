# KPD

**Ongoing — 持续开发中。** 当前公开开发源码，暂不提供应用下载。

KPD = **Keep / Pending / Delete**，一个直接整理 Finder 文件夹的原生 macOS 照片与视频工具。

- **Keep**：明确保留，先进入保留盒，确认后移入原目录下的 `Keep/`。
- **Pending**：暂不决定，不移动文件；下次打开同一文件夹仍出现在待整理列表。
- **Delete**：先标记，确认后移入 macOS 废纸篓，不永久删除。

未确认决策和撤销历史仅保存在当前会话内；退出前请处理完未确认操作。

## 开发

需要 macOS 14 或更新系统及 Swift 5.9 或更新工具链。

```sh
swift build
swift run KPDCoreSmokeTests
./script/build_and_run.sh --build-only
./script/build_and_run.sh
```

应用包为 `dist/KPD.app`，Bundle Identifier 为 `app.kpd.KPD`。
构建不会强制结束运行中的应用。打包资源随应用携带，无需源码目录。

## 数据与升级

偏好设置使用应用的 UserDefaults 域。更换应用身份时应先备份，再一次性复制语言、外观、引导和排序设置；不迁移照片，不清除原偏好。

网页 QA 清单使用浏览器本地存储；升级前有已勾选记录时请先导出或记录，同一来源下只有一个旧版清单键时自动复制到新键，保留原记录；更换页面来源时需另行转移。

## 本机工具链说明

若默认 macOS 27 SDK 报告缺少 `SwiftUIMacros`，可使用已安装的 macOS 26.5 SDK：

```sh
SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk ./script/build_and_run.sh --build-only
swift run --sdk /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk KPDCoreSmokeTests
```

## 许可状态

KPD 暂未授予项目级开源许可。公开源码用于展示持续开发过程，不表示已按 MIT、GPL 或其他开源许可证授权。

第三方素材保留各自的许可，详见 [第三方声明](THIRD_PARTY_NOTICES.md)。
