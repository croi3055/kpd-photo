# Changelog

## Unreleased

### Changed

- Standardized the product, Swift modules, executable, resources, and documentation on KPD (Keep / Pending / Delete).
- Changed the application identity to `app.kpd.KPD`; existing preferences require a one-time transfer.
- Preserved all photo decisions and file operation behavior.
- Added build-only packaging and removed forced process termination from the build script.

### Added

- Planned V1 Grouping as the next product phase after core triage.

## v0.1.0 - 2026-06-22

### Added

- Added the initial product roadmap for a lightweight, Finder-native macOS photo triage app.
- Added the initial PRD covering goals, scope, UX requirements, file safety, performance, privacy, and milestones.
- Added the development process for devlogs, changelog entries, and architecture decision records.
- Added the initial SwiftPM macOS app scaffold.
- Added V0 folder scanning, on-demand image viewing, keyboard navigation, delete marking, undo, and confirmed Trash deletion.
- Added a project-local build and launch script.
- Added a smoke-test executable for core folder scanning.
- Added a V0 Polish QA run report.
- Added a first-run onboarding view with usage guidance and keyboard shortcuts.
- Added drag-and-drop folder opening from Finder.
- Added Settings with English and Chinese language choices.
- Added Settings with System, Light, and Dark appearance choices.
- Added a dedicated welcome window and separate per-folder organizer windows.
- Added support for opening another organizer window by dropping a folder onto an existing organizer window.
- Added initial local video support for common formats including `mov`, `mp4`, `m4v`, `avi`, and `mkv`.
- Added a first-launch onboarding alert.
- Added shortcut guidance to Settings.
- Added thumbnail-grid trash review with batch selection.
- Added in-memory video frame thumbnails in the trash review grid.
- Added a drag-target overlay when dropping folders or media onto an organizer window.
- Added app trash summary counts for photos and videos.
- Added app trash keyboard shortcuts for `Command+A` select/deselect all and `R` restore selected.
- Added in-window non-blocking notices for empty folders and duplicate folder drops.
- Added a focused media context menu with Show in Finder, Open in Preview, and AirDrop.
- Added `Esc` as an organizer-window close shortcut.

### Changed

- Updated the PRD to a bilingual English and Chinese format.
- Updated the main UI to use app-managed bilingual strings.
- Changed folder opening so each selected or dropped folder starts its own organizer window instead of replacing the current session.
- Changed the welcome screen to keep only the folder entry point and lightweight privacy promise.
- Changed shortcut guidance in Settings from prose rows to a native-looking action and keycap list.
- Shortened the first-launch onboarding alert so it no longer lists shortcuts.
- Reduced the minimum widths of the welcome, organizer, and settings windows.
- Localized app-controlled menu items for About, Settings, Open Folder, and Quit.
- Moved app UI copy into a manually editable JSON localization file.
- Added a manually editable keyboard shortcut mapping file.
- Changed mark-for-trash shortcuts to `↑` and `W`.
- Changed marked items to leave the browsing flow immediately and collect in an in-app trash bin.
- Added a clickable trash icon with a count badge in the browser status area.
- Added a trash bin review sheet for confirming macOS Trash moves.
- Added a close-window confirmation when an organizer window still has pending trash items.
- Added `Delete` as a shortcut for opening the in-app trash bin while browsing.
- Added support for organizing directly from multiple dropped image or video files, not only folders.
- Added a dedicated completion screen when trying to advance past the last media item, with a right-arrow hint to return to the first item.
- Added a toolbar sort toggle for newest-to-oldest and oldest-to-newest media ordering.
- Added persistent media sort preference so new folders and app launches keep the chosen time order.
- Added keyboard navigation, range selection, and spacebar preview to the trash review grid.
- Changed the media sort toggle icon from a clock metaphor to an A-Z/Z-A style icon.
- Changed trash range selection so Shift+arrow can shrink/cancel the temporary range, not only add items.
- Changed trash preview to support arrow-key navigation and removed the confirmation button from the preview sheet.
- Changed trash preview so Space opens and closes preview.
- Fixed trash Shift+arrow range selection so returning to the anchor can cancel the first temporary selection.
- Changed user-facing deletion terminology to distinguish the in-app Delete Queue from the system Trash.
- Changed user-facing deletion copy to use shorter "delete" wording and call the in-app holding area "Trash".
- Changed organizer windows to open through a dedicated scene so the welcome window stays open.
- Changed the welcome window to close automatically after opening a folder from the welcome screen.
- Changed organizer closing to show the welcome window again.
- Changed inline renaming to commit when clicking outside the filename field.
- Changed the trash button so pending items are shown only by the badge count, not by recoloring the icon.
- Changed default browsing order from filename order to file modification time, newest to oldest.
- Changed sort toggling to jump to the first item in the newly selected order so the browser updates visibly.
- Changed trash thumbnails to fixed square cells to prevent grid overlap.
- Updated welcome and onboarding copy to mention folders, photos, and videos as supported drop inputs.
- Centralized all app UI strings and placeholders in `LocalizableContent.json`.
- Added a Settings action to reload edited UI text from `LocalizableContent.json` without restarting during development.
- Simplified the welcome screen copy and removed the lightweight-design text block.
- Fixed video playback continuing after closing an organizer window.
- Added double-click rename from the status bar file name.
- Changed renaming to edit inline in the status bar instead of opening a rename sheet.
- Added a temporary macOS app icon with a stacked photo-card concept.
- Replaced the temporary icon with a larger transparent card-stack icon so it reads clearly at Dock size, without the visible white border.
- Added a V0 stabilization QA checklist for launch, browsing, sorting, trash, rename, localization, and baseline verification.
- Standardized user-facing deletion language so app-internal pending items use Trash wording and final confirmation actions use Delete wording.
- Changed restored trash items to return to the browsing list in the active sort order.
- Changed the user-facing product name to `KPD` while keeping the existing Swift target names for now.
- Changed organizer window titles to show the opened folder name instead of a generic Organizer title.
- Changed app window coordination so only one welcome window is restored, and only when the last organizer window closes.
- Changed folder opening to validate supported media before opening an organizer window.
- Changed duplicate folder opening to show a prompt instead of opening the same folder twice.
- Changed the Settings shortcut display for Add to Trash to show the primary `↑` shortcut.
- Changed app trash selection controls so Select All toggles to Deselect All, and Restore Selected changes to Restore All when all items are selected.
- Changed organizer drag feedback to blur the viewer area instead of applying a blue overlay.
- Changed folder picker title and message to use app-managed localization.
- Changed app commands to hide irrelevant default English menu items and localize app-controlled menu actions.
- Changed Edit menu pasteboard commands to app-managed localized Cut/Copy/Paste/Select All items.
- Changed app trash actions so Delete All is always visible and Delete Selected appears only when items are selected.
- Changed app trash Select All and Restore buttons to show keyboard-style shortcut hints.
- Shortened Restore Selected copy to Restore Selected/恢复所选.
- Changed the close-with-trash confirmation secondary action to Discard Changes/撤销更改, which closes the organizer without deleting pending trash items.
- Changed the welcome drop hot zone to a fixed 3:2 area with even default outer margins.
- Reduced the welcome window and drop hot zone size by roughly one third.
- Made empty-folder and duplicate-folder notices more prominent without making them modal.
- Changed the welcome drop hot zone and welcome window to a compact square layout.
- Removed the Select All keycap hint in the app trash footer to avoid button truncation.
- Updated app trash footer actions: Restore All appears with no selection, Select/Deselect All appears only after selection starts, Delete Selected uses `D`, and Delete All keeps `Command+D` as a tooltip-only shortcut.
- Replaced the close-with-trash alert with a small closable macOS confirmation window so the red window close button cancels the close prompt.
- Centered the app trash photo/video summary.
- Enlarged the organizer drop overlay hint.
- Added runtime localization for top-level app menus and removed unused Format/Services menu items.
- Changed undo shortcuts to `Z` and `Down Arrow`.
- Changed close-with-trash confirmation to use a small closable macOS window with compact capsule buttons and a primary Delete and Close action.
- Changed close-with-trash completion actions so both Delete and Close and Discard Changes close the organizer and return to the welcome window.

### Fixed

- Replaced SwiftUI `VideoPlayer` with an AppKit `AVPlayerView` bridge to avoid a crash when opening organizer windows on macOS.
- Fixed stale organizer state when opening a folder after returning to the welcome window.
- Fixed inline renaming not committing when clicking the viewer or another non-focusable area.
- Fixed reopening the same folder after closing an organizer window by giving each organizer launch a fresh session identity.
- Fixed confirmed deleted items remaining undoable after they leave the app trash.
- Fixed empty folders opening an organizer window before showing the no-supported-media message.
- Fixed video playback consuming Left/Right Arrow keys that should navigate between adjacent media items.
- Fixed app trash Shift+arrow range selection so selection and cancellation can continue across Shift key releases.
- Fixed duplicate Settings menu entries by registering app commands once for the scene group.
- Fixed duplicate-folder state remaining after closing an organizer window.
- Fixed organizer windows opened from another organizer keeping the generic Organizer title.
- Fixed close confirmation wording so the non-destructive close path is explicit.
- Fixed closed organizer windows leaving stale duplicate-folder state behind.
- Fixed opening a valid folder after an empty-folder drop leaving the welcome window visible behind the organizer.
- Fixed organizer shortcuts remaining active while the close-with-trash confirmation window is open.
- Fixed closing an organizer via `Esc` not restoring the welcome window.
