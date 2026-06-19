# WASD Photo Roadmap

WASD Photo is a lightweight, Finder-native macOS photo triage tool inspired by the fast browsing and sorting flow of Slidebox.

The product direction is deliberately different from Lightroom or Apple Photos: no library import, no copied originals, and no default persistent image cache.

## Product Principles

- Read photos directly from Finder folders.
- Do not import photos into an app-managed library.
- Do not copy original photos by default.
- Do not generate persistent image previews or thumbnail caches by default.
- Load images on demand while browsing.
- Keep only a small in-memory working set, such as the current image plus nearby images.
- Treat delete, move, rename, and tag changes as planned operations until the user confirms them.
- Move deleted photos to the macOS Trash instead of permanently deleting them.
- Prefer macOS-native UI and system integrations.
- Make every destructive or bulk operation reviewable and reversible where possible.

## Step 1: Define The Product Boundary

Before implementation, keep the core boundary clear:

- This is a file-folder based photo organizer.
- It operates on photos where they already live.
- It is not a catalog manager.
- It is not a cloud sync product.
- It is not an automatic cleanup tool that changes files without confirmation.

Every new feature should be checked against the question:

> Does this preserve the lightweight, no-library, no-default-cache promise?

## Step 2: Build The V0 MVP

The first version should prove the core browsing and deletion flow.

V0 features:

- Open a Finder folder using the system folder picker.
- Scan only for supported image file paths.
- Support common image formats: `jpg`, `jpeg`, `png`, `heic`, `heif`, `webp`, `tiff`, and `gif` where practical.
- Display the current photo in a large viewer.
- Navigate with left and right arrow keys.
- Mark the current photo for deletion.
- Undo the most recent mark action.
- Show the current position, such as `12 / 438`.
- Show the current file name and operation state.
- Confirm the pending delete queue.
- Move confirmed deletes to the macOS Trash.

V0 non-goals:

- No persistent image cache.
- No photo import.
- No database-backed catalog.
- No AI classification.
- No duplicate detection.
- No advanced metadata editing.

## Step 3: Create The macOS App Foundation

Recommended stack:

- Swift
- SwiftUI
- AppKit only where SwiftUI needs native macOS escape hatches
- `FileManager` for file operations
- `NSOpenPanel` or SwiftUI file importer for folder selection
- `FileManager.trashItem(at:resultingItemURL:)` for safe deletion

Suggested project structure:

```text
WASDPhoto/
  App/
  Models/
  Services/
  ViewModels/
  Views/
  Resources/
```

Core modules:

- `FolderScanner`: Finds supported image files in a selected folder.
- `ImageLoader`: Loads the current image on demand without writing previews to disk.
- `PhotoSession`: Owns the current folder, current index, and photo list.
- `ActionQueue`: Tracks pending delete, move, rename, and tag operations.
- `TrashService`: Moves confirmed delete targets to the macOS Trash.
- `KeyboardCommandRouter`: Maps keyboard shortcuts to session actions.

## Step 4: Design The First UI

The first UI should be boring in the best way: native, fast, and obvious.

Initial layout:

- Center: large current photo.
- Top toolbar: open folder, undo, confirm actions.
- Top or bottom status area: file name, current index, pending action state.
- Optional side panel: pending operations summary.

Initial shortcuts:

- `Left Arrow`: previous photo.
- `Right Arrow`: next photo.
- `Delete` or `Backspace`: mark for deletion.
- `Z`: undo last action.
- `Enter`: confirm relevant dialog action.
- `Space`: reserved for future preview behavior.

## Step 5: Add Safety Rules

Photo cleanup needs conservative defaults.

Safety requirements:

- Never permanently delete files in normal operation.
- Deletion means moving to the macOS Trash.
- Marking a file for deletion should not immediately alter the file.
- Bulk actions require an explicit confirmation sheet.
- The confirmation sheet should show the number of affected files.
- Failed operations should be reported clearly.
- File-not-found, permission, and conflict errors should not stop unrelated operations unless necessary.

## Step 6: Add Slidebox-Style Grouping

After V0 feels good, add grouping.

Grouping features:

- Create named groups.
- Assign photos to groups with number keys.
- Show the pending group assignment in the viewer.
- Confirm moves in a batch.
- Move files into corresponding subfolders after confirmation.
- Optionally support Finder tags instead of moving files.

Possible shortcuts:

- `1` through `9`: assign the current photo to a group.
- `0`: clear group assignment.
- `G`: open group editor.

## Step 7: Add Planned Renaming

Renaming should follow the same non-destructive planning model.

Renaming features:

- Generate rename plans without immediately touching files.
- Preview old and new names before execution.
- Detect conflicts before applying changes.
- Never silently overwrite files.
- Support date, sequence number, and optional tag-based naming.

Example:

```text
IMG_3021.HEIC
-> 2024-10-Paris-Street-001.HEIC
```

## Step 8: Add Lightweight Tags

Tags should work without a photo library.

Tag options:

- Session-only tags for temporary sorting.
- Finder tags for tags visible in macOS Finder.
- Optional sidecar metadata for users who want portable project state.

Default behavior:

- Do not create sidecar files unless the user enables that feature.
- Prefer Finder tags for native macOS visibility.

## Step 9: Add Similar Photo Detection

Similarity detection should arrive after the manual workflow is solid.

Default no-cache mode:

- Read image data temporarily.
- Compute perceptual hashes in memory.
- Group visually similar images.
- Discard results when the session ends.

Optional lightweight index mode:

- Store only small hash or feature values.
- Do not store thumbnails or previews.
- Show estimated disk usage.
- Provide a one-click clear option.

## Step 10: Add AI-Assisted Classification

AI classification should be assistant-like, not automatic file control.

Possible categories:

- Landscape
- Portrait
- City
- Animal
- Food
- Screenshot
- Document
- Night
- Indoor
- Blurry or low quality

Rules:

- Run classification only when the user asks for it.
- Present results as suggestions.
- Require confirmation before applying tags, groups, moves, or renames.
- Be explicit about privacy and whether image data leaves the machine.

## Step 11: Polish The macOS Experience

Native polish should come after the core loop works.

Targets:

- Native toolbar.
- Native sidebar.
- Dark mode.
- Full-screen browsing.
- Trackpad gestures.
- Recent folders.
- Drag folder onto app icon to open.
- Finder right-click service or Quick Action.
- Robust permission handling for external drives and removable media.

## First Implementation Milestone

The first milestone is a usable V0:

1. Create the SwiftUI macOS project.
2. Open a folder from Finder.
3. Scan image file paths without generating a cache.
4. Display the first image.
5. Navigate with left and right arrow keys.
6. Mark photos for deletion.
7. Undo the latest mark.
8. Confirm and move marked photos to the macOS Trash.

This milestone is intentionally small. Its job is to prove the browsing feel, keyboard flow, and safety model.
