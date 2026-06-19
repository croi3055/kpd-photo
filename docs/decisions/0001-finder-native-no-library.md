# 0001: Finder-Native No-Library Model

## Status

Accepted

## Context

The app is intended to be a lightweight macOS photo browsing, deletion, and grouping tool. The user explicitly does not want Lightroom-style imports, app-managed photo libraries, or large generated image caches.

## Decision

The app will read photos directly from Finder folders. It will not import originals into an app-managed library, copy original files by default, or generate persistent image previews by default.

## Consequences

This keeps the app lightweight, transparent, and aligned with Finder. It also means some advanced features, such as similar photo detection and AI classification, may need to recompute results in no-cache mode unless the user explicitly enables a lightweight metadata index.
