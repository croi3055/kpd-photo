# Development Process

This project should be built in a traceable way. The goal is to make product decisions, implementation changes, and release history easy to reconstruct later.

## Working Principles

- Keep changes small and reviewable.
- Record why important decisions were made, not only what changed.
- Prefer working software over large speculative design documents.
- Keep user-facing behavior documented as it evolves.
- Treat destructive file operations with extra care.
- Verify no-library, no-import, and no-default-cache behavior whenever related code changes.

## Project Records

The project should maintain these records:

```text
docs/
  ROADMAP.md
  DEVELOPMENT_PROCESS.md
  devlog/
  decisions/
CHANGELOG.md
```

Recommended purpose:

- `ROADMAP.md`: Product direction and milestone plan.
- `DEVELOPMENT_PROCESS.md`: How development is tracked.
- `docs/devlog/`: Dated development notes.
- `docs/decisions/`: Architecture decision records.
- `CHANGELOG.md`: User-facing changes by version or milestone.

## Development Log

Create a devlog entry for meaningful work sessions.

Suggested filename format:

```text
docs/devlog/YYYY-MM-DD.md
```

Suggested entry format:

```markdown
# YYYY-MM-DD

## Goal

- What we intended to accomplish.

## Changes

- What changed in the app, docs, tests, or project structure.

## Decisions

- Any product or technical decisions made during the session.

## Verification

- Commands run, builds attempted, manual checks, or known gaps.

## Next

- The most likely next steps.
```

The devlog is for project memory. It can include rough notes, tradeoffs, and work-in-progress details that do not belong in the changelog.

## Changelog

Maintain `CHANGELOG.md` for user-facing changes.

Suggested format:

```markdown
# Changelog

## Unreleased

### Added

- ...

### Changed

- ...

### Fixed

- ...

### Removed

- ...
```

Use the changelog for things a user would care about:

- New features.
- Behavior changes.
- Bug fixes.
- Removed features.
- Compatibility notes.
- Important safety changes.

Avoid filling the changelog with internal refactors unless they affect user-visible behavior.

## Architecture Decision Records

Use architecture decision records for choices that shape the app.

Suggested filename format:

```text
docs/decisions/0001-short-title.md
```

Suggested format:

```markdown
# 0001: Short Title

## Status

Accepted

## Context

What situation or problem led to this decision?

## Decision

What did we decide?

## Consequences

What becomes easier, harder, or intentionally out of scope?
```

Initial decisions worth recording:

- The app reads Finder folders directly instead of importing photos.
- The app does not create persistent image caches by default.
- Delete actions move files to the macOS Trash.
- The UI should use native macOS SwiftUI patterns.

## Suggested Workflow Per Feature

For each meaningful feature:

1. Clarify the user-facing behavior.
2. Update or create a short devlog goal.
3. Implement the smallest coherent change.
4. Add focused tests where practical.
5. Build or run the app.
6. Manually verify the user flow.
7. Update the devlog with what happened.
8. Update `CHANGELOG.md` if the behavior is user-visible.
9. Add a decision record if the change locks in a long-term direction.

## Verification Checklist

Use this checklist when touching file browsing, loading, deletion, grouping, tagging, or renaming:

- Does this create any persistent image cache?
- Does this copy originals without explicit user intent?
- Does this permanently delete anything?
- Does this allow the user to review bulk changes?
- Does this handle missing files and permission errors clearly?
- Does this preserve the Finder-native mental model?
- Does this still feel like a lightweight macOS app?

## Commit Style

When using git commits, prefer small commits with direct messages.

Examples:

```text
docs: add product roadmap
app: add folder scanner
app: mark photos for deletion
app: move confirmed deletes to trash
```

Each commit should ideally correspond to one understandable unit of progress.

## Release Milestones

Suggested milestone labels:

- `v0.1`: Folder browsing and safe delete queue.
- `v0.2`: Group assignment and batch move.
- `v0.3`: Planned rename preview.
- `v0.4`: Finder tags.
- `v0.5`: Similar photo detection.
- `v0.6`: AI-assisted classification.

The version numbers can change later, but keeping milestone names early will help the project stay legible.
