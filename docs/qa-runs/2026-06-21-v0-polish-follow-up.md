# QA Run - 2026-06-21 - V0 Polish Follow-Up

## Summary

Status: Fix batch implemented; needs user re-test.

This run records manual QA findings from the user and the fixes implemented in response.

## Failed Items Addressed

| Item | Status | Fix |
| --- | --- | --- |
| Empty folders opened an organizer window before showing the no-media message. | Fixed | Folder/media inputs are validated before opening organizer windows. |
| Left/Right Arrow adjusted video progress instead of browsing adjacent items. | Fixed | Organizer keyboard handling now uses a window-level local monitor so browsing shortcuts take precedence. |
| Trash Shift+arrow range selection was split by Shift key release. | Fixed | Range selection now supports both insert and remove modes based on the anchor selection state. |
| Closing each organizer window created a welcome window. | Fixed | A shared window coordinator tracks organizer count and only restores welcome when the last organizer closes. |
| Dropping an already open folder opened a duplicate organizer. | Fixed | Open folder keys are tracked and duplicate folder opens show a prompt. |
| Organizer window drop target had no interaction feedback. | Fixed | Added a drag-target overlay while dragging files over an organizer window. |
| Menu bar showed both localized Settings and default Settings. | Fixed | Commands are now registered once for the scene group. |
| Organizer window title was always Organizer. | Fixed | Organizer window title now shows the opened folder name. |
| Settings showed the wrong Add to Trash shortcut. | Fixed | Settings now displays `↑` as the primary Add to Trash shortcut. |
| Trash lacked Command+A, R restore, all-selection button state, and media counts. | Fixed | Added `Command+A`, `R`, Select/Deselect All, Restore All, and photo/video counts. |

## Passed Items From Manual QA

- Closing organizer returns to the welcome window.
- Video audio stops after closing the organizer.
- Trash thumbnails do not visually overlap.
- Trash Space preview works.
- Clicking outside the filename commits inline rename.
- Light/dark mode, language switching, and icon appearance are acceptable.

## Verification

- `swift build` passed.
- `swift run WASDPhotoCoreSmokeTests` passed.
- `./script/build_and_run.sh --verify` passed.

## Retest Needed

- Empty-folder drop should stay on welcome and show a non-blocking in-window notice.
- Left/Right Arrow should browse adjacent media while a video is focused.
- Trash Shift+arrow should both select and cancel even after releasing Shift.
- Multiple organizer windows should not create duplicate welcome windows.
- Duplicate folder drop should show a non-blocking in-window notice.
- Closing an organizer and reopening the same folder should not trigger the duplicate-folder notice.
- Organizer drop overlay should blur the viewer area and should not turn the surface blue.
- Menu should show only one Settings item and app-controlled menu items should follow the selected language.
- Organizer title should show the folder name.
- Settings Add to Trash shortcut should show `↑`.
- Trash should support `Command+A`, `R`, dynamic Select/Deselect All, Restore All, Delete All always visible, Delete Selected only when selected, and photo/video counts.
- Closing with pending trash should offer Discard Changes/撤销更改, close the organizer, and leave files undeleted.
- Trash footer should show Restore All/Delete All when nothing is selected, show Select/Deselect All only after selection starts, and support `D` for Delete Selected plus `Command+D` for Delete All.
- Close-with-trash confirmation should use a small closable macOS window; the red close button should dismiss the prompt without closing the organizer.
- The Format and Services menu entries should be gone, and top-level app menus should follow app language where possible.

## Follow-Up Optimizations

- Align the close-with-trash confirmation button styling with the welcome screen Open Folder button style. Current behavior is acceptable for V0 polish, but the visual language should be unified before a broader beta.
