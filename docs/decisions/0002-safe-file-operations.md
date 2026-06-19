# 0002: Safe File Operations

## Status

Accepted

## Context

The app will help users delete, move, group, tag, and rename photos. These operations can affect valuable personal files, so the workflow must be conservative.

## Decision

Destructive or bulk operations will be represented as planned actions first. The user must confirm them before execution. Delete operations will move files to the macOS Trash rather than permanently deleting them.

## Consequences

This adds an extra confirmation step, but it reduces the risk of accidental data loss and matches the lightweight, user-controlled product direction.
