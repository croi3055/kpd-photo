# untitled-photo-organizer PRD / 产品需求文档

## 1. Overview / 概览

untitled-photo-organizer is a lightweight, native macOS photo and video browsing and triage app for media stored in normal Finder folders.

untitled-photo-organizer 是一个轻量、原生的 macOS 照片与视频浏览整理工具，面向存放在普通 Finder 文件夹里的媒体文件。

It is designed for users who want the speed of a phone-style photo cleanup flow, but do not want a Lightroom-style library, import process, copied originals, or persistent preview cache.

它面向想要手机式快速清理体验、但不想使用 Lightroom 式图库、导入流程、原图复制或持久预览缓存的用户。

The app should feel like a focused Finder companion: open a folder, quickly browse photos, mark actions, review them, and apply them safely.

这个 app 应该像一个专注的 Finder 伙伴：打开文件夹，快速浏览照片，标记操作，统一检查，然后安全执行。

## 2. Goals / 目标

- Provide fast keyboard-first browsing for local photo and video folders.
- 为本地照片和视频文件夹提供快速、键盘优先的浏览体验。
- Let users safely mark photos for deletion and move them to the macOS Trash after confirmation.
- 让用户安全地标记待删除照片，并在确认后将它们移入 macOS 废纸篓。
- Support lightweight grouping, tagging, and renaming without creating an app-managed photo library.
- 支持轻量分组、标签和重命名，同时不创建 app 托管的照片图库。
- Preserve user trust by making file changes explicit, reviewable, and reversible where possible.
- 通过明确、可检查、尽可能可撤销的文件变更来维护用户信任。
- Use native macOS UI patterns instead of a cross-platform or web-app feel.
- 使用原生 macOS UI 模式，而不是跨平台或网页应用风格。
- Keep the app lightweight by default: no import, no copied originals, and no persistent image cache.
- 默认保持轻量：不导入、不复制原图、不创建持久图片缓存。

## 3. Non-Goals / 非目标

- Do not replace Lightroom, Apple Photos, or a DAM system.
- 不替代 Lightroom、Apple Photos 或数字资产管理系统。
- Do not create an app-managed photo library.
- 不创建 app 托管的照片图库。
- Do not import or copy photos by default.
- 默认不导入或复制照片。
- Do not generate persistent image previews or thumbnails by default.
- 默认不生成持久图片预览或缩略图。
- Do not permanently delete files in the normal delete flow.
- 在普通删除流程中不永久删除文件。
- Do not automatically upload image data for AI processing.
- 不自动上传图片数据用于 AI 处理。
- Do not auto-apply destructive cleanup decisions without user confirmation.
- 未经用户确认，不自动执行破坏性清理决策。

## 4. Target Users / 目标用户

Primary users:

主要用户：

- People who keep photos in Finder folders.
- 将照片保存在 Finder 文件夹中的用户。
- People who want to clean up screenshots, camera dumps, travel photos, or exported phone photos quickly.
- 想快速清理截图、相机导出、旅行照片或手机导出照片的用户。
- People who dislike heavy catalog-based workflows.
- 不喜欢重型图库或 catalog 工作流的用户。
- People who care about knowing exactly where their files live.
- 重视文件实际存放位置透明可控的用户。

Secondary users:

次要用户：

- Photographers who want a quick pre-culling tool before using heavier editing software.
- 希望在进入重型修图软件前快速初筛照片的摄影用户。
- Users working with external drives, SD card dumps, or NAS folders.
- 使用外接硬盘、SD 卡导出文件夹或 NAS 文件夹的用户。

## 5. Core Product Principles / 核心产品原则

- Finder-native: photos stay in their original folders unless the user confirms a move.
- Finder 原生：除非用户确认移动，否则照片保留在原始文件夹中。
- No library: the app does not create a managed photo catalog.
- 无图库：app 不创建托管照片 catalog。
- No default image cache: browsing should not produce persistent preview files.
- 默认无图片缓存：浏览过程不应产生持久预览文件。
- Planned operations first: delete, move, rename, and tag changes are queued before execution.
- 先计划后执行：删除、移动、重命名和标签变更先进入队列，再执行。
- Trash-first deletion: delete means move to the macOS Trash.
- 删除进废纸篓：删除意味着移入 macOS 废纸篓。
- Native macOS feel: SwiftUI, system controls, standard toolbar/sidebar patterns, dark mode.
- 原生 macOS 质感：SwiftUI、系统控件、标准工具栏和侧边栏模式、深色模式。
- User control: AI and automation suggest actions, but do not silently apply them.
- 用户掌控：AI 和自动化只能建议操作，不能静默执行。

## 6. V0 Scope / V0 范围

V0 should deliver the smallest useful workflow: open a folder, browse photos, mark deletes, undo, and confirm.

V0 应交付最小可用流程：打开文件夹、浏览照片、标记删除、撤销、确认执行。

### 6.1 Functional Requirements / 功能需求

- The user can open a Finder folder with a system folder picker or by dragging a folder onto the welcome window.
- 用户可以通过系统文件夹选择器打开 Finder 文件夹，也可以将文件夹拖到欢迎窗口。
- Each opened folder starts an independent organizer window.
- 每个打开的文件夹都会启动一个独立的整理窗口。
- Dropping another folder onto an organizer window opens a new organizer window.
- 将另一个文件夹拖到整理窗口时，会打开新的整理窗口。
- Closing an organizer window returns the user to the welcome window when it remains open.
- 关闭整理窗口后，用户回到仍然打开的欢迎窗口。
- The app scans the selected folder for supported image file paths.
- app 扫描所选文件夹中的受支持图片文件路径。
- The app displays the first available photo.
- app 显示第一张可用照片。
- The user can move to the previous or next photo with keyboard shortcuts.
- 用户可以通过键盘快捷键切换上一张或下一张照片。
- The user can mark the current photo for deletion.
- 用户可以将当前照片标记为待删除。
- The user can undo the most recent mark action.
- 用户可以撤销最近一次标记操作。
- The app shows current position, file name, and pending state.
- app 显示当前位置、文件名和待处理状态。
- The user can review the delete queue.
- 用户可以检查删除队列。
- The user can confirm deletion.
- 用户可以确认删除。
- Confirmed deletion moves files to the macOS Trash.
- 确认删除后，文件被移入 macOS 废纸篓。

### 6.2 Supported Image Formats / 支持的图片格式

Initial supported formats:

初始支持格式：

- `jpg`
- `jpeg`
- `png`
- `heic`
- `heif`
- `webp`
- `tiff`
- `gif` where practical / 在可行情况下支持 `gif`
- `mov`
- `mp4`
- `m4v`
- `avi`
- `mkv`

RAW and additional video format support can be evaluated later.

RAW 和更多视频格式支持可在后续阶段评估。

### 6.3 V0 Out Of Scope / V0 暂不包含

- Grouping.
- 分组。
- Renaming.
- 重命名。
- Finder tags.
- Finder 标签。
- Similar photo detection.
- 相似照片识别。
- AI classification.
- AI 分类。
- Persistent session restore.
- 持久会话恢复。
- External metadata sidecars.
- 外部元数据 sidecar 文件。
- Custom app-managed catalog.
- 自定义 app 托管 catalog。

## 7. Future Scope / 未来范围

### 7.1 V1: Grouping / V1：分组

- Create named groups.
- 创建命名分组。
- Assign photos to groups with number keys.
- 使用数字键将照片分配到分组。
- Review pending moves.
- 检查待移动操作。
- Move files into group folders after confirmation.
- 确认后将文件移动到对应分组文件夹。
- Optionally use Finder tags instead of moving files.
- 可选使用 Finder 标签，而不是移动文件。

### 7.2 V2: Renaming / V2：重命名

- Generate rename plans.
- 生成重命名预案。
- Preview old and new names.
- 预览旧文件名和新文件名。
- Detect conflicts.
- 检测冲突。
- Apply confirmed renames only.
- 只执行已确认的重命名。
- Support date and sequence-based patterns.
- 支持基于日期和序号的命名模式。

### 7.3 V3: Finder Tags / V3：Finder 标签

- Apply macOS Finder tags.
- 应用 macOS Finder 标签。
- Support session-only tags.
- 支持仅本次会话使用的标签。
- Keep sidecar metadata optional.
- sidecar 元数据保持可选。

### 7.4 V4: Similar Photo Detection / V4：相似照片识别

- Compute perceptual hashes in memory by default.
- 默认在内存中计算感知哈希。
- Group similar photos.
- 将相似照片分组。
- Suggest likely keepers based on dimensions, file size, date, or image quality heuristics.
- 基于尺寸、文件大小、日期或图像质量启发式规则建议保留项。
- Keep persistent feature indexes optional and explicitly user-enabled.
- 持久特征索引保持可选，并且必须由用户明确启用。

### 7.5 V5: AI-Assisted Classification / V5：AI 辅助分类

- Suggest tags like landscape, portrait, city, animal, food, screenshot, document, night, indoor, and blurry.
- 建议风景、人像、城市、动物、食物、截图、文档、夜景、室内、模糊等标签。
- Require user confirmation before applying AI suggestions.
- 应用 AI 建议前必须获得用户确认。
- Make privacy behavior explicit.
- 明确说明隐私行为。

## 8. User Experience Requirements / 用户体验需求

### 8.1 Main Window / 主窗口

The first UI should include:

第一版 UI 应包含：

- A large central image viewer.
- 中央大图浏览器。
- A native toolbar with open folder, undo, and confirm actions.
- 包含打开文件夹、撤销和确认操作的原生工具栏。
- A status area with file name, current index, and pending action state.
- 显示文件名、当前序号和待处理状态的状态区域。
- An optional operation summary area for queued changes.
- 可选的队列操作摘要区域。

### 8.2 Keyboard Shortcuts / 键盘快捷键

V0 shortcuts:

V0 快捷键：

- `Left Arrow`: previous photo.
- `Left Arrow`：上一张照片。
- `Right Arrow`: next photo.
- `Right Arrow`：下一张照片。
- `Delete` or `Backspace`: mark current photo for deletion.
- `Delete` 或 `Backspace`：将当前照片标记为待删除。
- `Z`: undo last action.
- `Z`：撤销上一步操作。
- `Enter`: confirm when a confirmation sheet is focused.
- `Enter`：当确认 sheet 获得焦点时执行确认。
- `Escape`: close dialogs or cancel transient UI where appropriate.
- `Escape`：在合适场景下关闭对话框或取消临时 UI。

Reserved future shortcuts:

预留未来快捷键：

- `1` through `9`: assign to group.
- `1` 到 `9`：分配到分组。
- `0`: clear group assignment.
- `0`：清除分组分配。
- `G`: edit groups.
- `G`：编辑分组。
- `Space`: preview or fit behavior, to be decided after testing.
- `Space`：预览或适配窗口行为，测试后决定。

### 8.3 Empty And Error States / 空状态与错误状态

The app should clearly handle:

app 应清晰处理：

- No folder selected.
- 未选择文件夹。
- Folder contains no supported images.
- 文件夹中没有受支持的图片。
- File was moved or deleted outside the app.
- 文件在 app 外被移动或删除。
- Permission denied.
- 权限不足。
- External drive disconnected.
- 外接硬盘断开。
- Trash operation failed.
- 移入废纸篓失败。

## 9. File Operation Requirements / 文件操作需求

- The app must not permanently delete files in V0.
- app 在 V0 中不得永久删除文件。
- Marking deletion must not change the file immediately.
- 标记删除不得立即修改文件。
- Confirmed deletion must use the macOS Trash.
- 确认删除必须使用 macOS 废纸篓。
- Batch operations must show a confirmation sheet.
- 批量操作必须显示确认 sheet。
- The app must report partial failures.
- app 必须报告部分失败。
- The app must not silently overwrite files.
- app 不得静默覆盖文件。
- The app must preserve file extensions during rename operations.
- 重命名操作必须保留文件扩展名。
- The app should avoid following surprising destructive behavior for symlinks until explicitly designed.
- 在明确设计前，app 应避免对符号链接执行可能令人意外的破坏性行为。

## 10. Performance Requirements / 性能需求

- Opening a folder should feel immediate for ordinary folders.
- 打开普通文件夹时应感觉即时。
- Scanning should collect paths and basic metadata, not generate thumbnails.
- 扫描应收集路径和基础元数据，而不是生成缩略图。
- The image loader should load images on demand.
- 图片加载器应按需加载图片。
- The app may keep a small in-memory working set, such as current, previous, and next images.
- app 可以保留小规模内存工作集，例如当前、上一张和下一张图片。
- The app should release memory when moving through large folders.
- 浏览大型文件夹时，app 应释放不再需要的内存。
- The app should not write preview images or thumbnail caches to disk by default.
- app 默认不应将预览图或缩略图缓存写入磁盘。

## 11. Privacy Requirements / 隐私需求

- Local browsing and deletion must not require network access.
- 本地浏览和删除不得要求网络访问。
- AI features must be opt-in.
- AI 功能必须是用户主动启用。
- Any feature that sends image data outside the machine must disclose that clearly before use.
- 任何会将图片数据发送到本机之外的功能，都必须在使用前明确说明。
- The app should support a fully local workflow.
- app 应支持完全本地的工作流。

## 12. Technical Direction / 技术方向

Recommended implementation:

推荐实现：

- Swift
- SwiftUI
- AppKit interop only where needed for native macOS behavior
- 仅在原生 macOS 行为需要时使用 AppKit 互操作。
- `FileManager` for file operations
- 使用 `FileManager` 进行文件操作。
- `FileManager.trashItem(at:resultingItemURL:)` for Trash behavior
- 使用 `FileManager.trashItem(at:resultingItemURL:)` 实现移入废纸篓。
- `NSOpenPanel` or SwiftUI file importer for folder selection
- 使用 `NSOpenPanel` 或 SwiftUI file importer 进行文件夹选择。

Initial modules:

初始模块：

- `FolderScanner`
- `ImageLoader`
- `PhotoSession`
- `ActionQueue`
- `TrashService`
- `KeyboardCommandRouter`

## 13. Success Metrics / 成功标准

V0 is successful if:

如果满足以下条件，则 V0 成功：

- A user can open a folder and start browsing without importing anything.
- 用户可以打开文件夹并开始浏览，无需导入任何内容。
- Left and right navigation feels responsive.
- 左右切换响应迅速。
- The user always understands whether a photo is marked for deletion.
- 用户始终清楚某张照片是否被标记为待删除。
- The user can undo accidental marks.
- 用户可以撤销误标记。
- Confirmed deletes go to the macOS Trash.
- 确认删除的文件进入 macOS 废纸篓。
- No persistent image cache is created during normal browsing.
- 普通浏览过程中不会创建持久图片缓存。

Longer-term success:

长期成功标准：

- Users can triage large photo folders faster than with Finder alone.
- 用户整理大型照片文件夹的速度比单独使用 Finder 更快。
- Users trust the app with personal photos.
- 用户信任这个 app 来处理个人照片。
- The app remains lightweight as grouping, renaming, similar detection, and AI assistance are added.
- 随着分组、重命名、相似识别和 AI 辅助加入，app 仍保持轻量。

## 14. Open Questions / 开放问题

- Should V0 scan subfolders, or only the selected folder?
- V0 应扫描子文件夹，还是只扫描所选文件夹？
- Should delete marking automatically advance to the next photo?
- 标记删除后是否应自动跳到下一张照片？
- Should the app sort by file name, creation date, modification date, or Finder order?
- app 应按文件名、创建日期、修改日期还是 Finder 顺序排序？
- Should grouped files move immediately after confirmation, or should grouping be session-only until export?
- 分组文件应在确认后立即移动，还是分组只在会话内存在直到导出？
- Should Finder tags be preferred over folder moves for some workflows?
- 某些工作流是否应优先使用 Finder 标签，而不是移动文件夹？
- How much RAW support is needed for early users?
- 早期用户需要多大程度的 RAW 支持？
- Should session restore be enabled without violating the no-library principle?
- 是否可以在不违反无图库原则的前提下启用会话恢复？

## 15. Milestones / 里程碑

- `v0.1.0`: Core triage complete: folder/file browsing, photo/video support, delete queue, trash review, restore, final delete, inline rename, sorting, localization, keyboard shortcuts, right-click actions, and compact welcome flow.
- `v0.1.0`：核心整理流程完成：文件夹/文件浏览、图片/视频支持、删除队列、垃圾桶复查、恢复、最终删除、内联重命名、排序、多语言、快捷键、右键菜单和紧凑初始界面。
- `V1`: Grouping: group assignment and batch move.
- `V1`：分组：分组分配和批量移动。
- `v0.3`: Rename preview and apply.
- `v0.3`：重命名预览和执行。
- `v0.4`: Finder tags.
- `v0.4`：Finder 标签。
- `v0.5`: Similar photo detection.
- `v0.5`：相似照片识别。
- `v0.6`: AI-assisted classification.
- `v0.6`：AI 辅助分类。
