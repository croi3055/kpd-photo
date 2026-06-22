# untitled-photo-organizer QA Checklist

This checklist is for the V0 stabilization pass. It focuses on existing behavior only: browsing, trash, sorting, renaming, text, and window lifecycle.

## 1. Launch And Opening

- Launch the app from a clean state.
- Confirm the welcome window appears.
- Drag in a folder with supported photos.
- Confirm the welcome window closes and an organizer window opens.
- Close the organizer window.
- Confirm the welcome window appears again.
- Reopen the same folder from the Dock-returned welcome window.
- Confirm the viewer shows media, not the stale welcome drop state.
- Drag supported image and video files directly into the welcome window.
- Confirm an organizer opens for those files.

## 2. Browsing And Sorting

- Confirm the default order is newest to oldest by file modification time.
- Toggle the A-Z/Z-A sort button.
- Confirm the visible media changes and the list order reverses.
- Close and relaunch the app.
- Confirm the last selected sort order is preserved.
- Browse to the last item.
- Press Right Arrow once more.
- Confirm the completion screen appears instead of an alert.
- Press Right Arrow on the completion screen.
- Confirm browsing returns to the first item.

## 3. Trash Flow

- Press Up Arrow or W on a media item.
- Confirm the item disappears from browsing and the trash badge increments.
- Open the app trash with the badge or Delete key.
- Confirm thumbnails are square and do not overlap.
- Use arrow keys to move focus.
- Press Enter to select and unselect the focused item.
- Use Shift+arrow to extend selection.
- Move back with Shift+arrow and confirm temporary selections can shrink or cancel.
- Press Space to preview the focused item.
- Use arrow keys inside preview to switch items.
- Press Space again to close preview.
- Restore selected items and confirm they return to browsing in the active sort order.
- Delete selected items and confirm only those items leave the app trash.
- Close an organizer with pending trash items.
- Confirm the close prompt uses short delete wording.

## 4. Rename Flow

- Double-click the file name in the status bar.
- Type a new base name and press Return.
- Confirm the file is renamed on disk and in the status bar.
- Double-click the file name again.
- Type a different name and click outside the field.
- Confirm clicking outside commits the rename.
- Try an empty name.
- Confirm the app shows a clear validation error.
- Try a name that already exists in the same folder.
- Confirm the app shows a conflict error and does not overwrite the file.

## 5. Text And Localization

- Open Settings.
- Switch between English and Chinese.
- Confirm app-controlled menus, toolbar labels, settings labels, alerts, and trash labels update.
- Edit `Sources/WASDPhoto/Resources/LocalizableContent.json`.
- Use Reload Text in Settings.
- Confirm edited UI text updates without rebuilding during development.
- Confirm the app-internal holding area is consistently called Trash/垃圾桶.
- Confirm final confirmation actions use Delete/删除 wording.

## 6. V0 Baseline Verification

- Run `swift build`.
- Run `swift run WASDPhotoCoreSmokeTests`.
- Run `./script/build_and_run.sh --verify`.
- Review `CHANGELOG.md`.
- Review the current git diff.
- Create the V0 baseline commit after verification passes.
