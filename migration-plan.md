# Migration Plan — Objective‑C to Modern Swift

## 0) Scope & parity goals
- Preserve CLI flags and behavior: `-v -l -e -s -y -F` and silently accepted `rm` flags.
- Preserve “put back” compatibility when using Finder-based trashing.
- Keep output formatting and error messages functionally equivalent.
- Target modern macOS + Swift (recommend macOS 12+ and Swift 5.9+ unless you need older).

## 1) Codebase inventory (source of truth)
- Core CLI and app logic: [obj-c/trash.m](obj-c/trash.m)
- CLI utilities and output encoding: [obj-c/HGCLIUtils.h](obj-c/HGCLIUtils.h) and [obj-c/HGCLIUtils.m](obj-c/HGCLIUtils.m)
- File size formatting: [obj-c/HGUtils.h](obj-c/HGUtils.h) and [obj-c/HGUtils.m](obj-c/HGUtils.m)
- Directory size calculation (FSRef-based): [obj-c/fileSize.h](obj-c/fileSize.h) and [obj-c/fileSize.m](obj-c/fileSize.m)
- Finder scripting interface (auto-generated): [obj-c/Finder.h](obj-c/Finder.h) from [obj-c/Finder.sdef](obj-c/Finder.sdef)
- Man page source: [obj-c/trash.pod](obj-c/trash.pod)
- Build: [obj-c/Makefile](obj-c/Makefile)

## 2) Decide the Swift packaging approach
- Use SwiftPM for a modern CLI package.
- Proposed structure:
  - Sources/TrashCLI/main.swift (argument parsing, command dispatch)
  - Sources/TrashCore/TrashService.swift (trash/empty/list operations)
  - Sources/TrashCore/FinderBridge.swift (Finder/Apple Events implementation)
  - Sources/TrashCore/FileSystem.swift (symlink‑safe exists, size aggregation)
  - Sources/TrashCore/Formatting.swift (size formatting, verbose logging)
- Add dependency on swift-argument-parser for robust CLI parsing.

## 3) Replace deprecated Carbon/FSRef usage
- Current: `FSMoveObjectToTrashSync`, `FSRef`, `FSPathMakeRefWithOptions`.
- Swift replacement:
  - Use `FileManager.trashItem(at:resultingItemURL:)` for standard trashing.
  - For existence checks without following leaf symlinks, prefer `lstat()` or `FileManager.attributesOfItem(atPath:)` with error handling.
- Keep a fallback path list for Finder trashing when permission is denied.

## 4) Finder-based trashing (for “put back”)
- Current: Apple Event `core/delo` with list of `furl` descriptors.
- Swift options:
  1) Apple Events via `NSAppleEventDescriptor` and `AESendMessage` (closest to current behavior).
  2) ScriptingBridge in Swift (generate a Swift-friendly interface if needed).
- Keep behavior:
  - Batch delete to avoid multiple auth prompts.
  - Optionally bring Finder to front only when used as fallback.

## 5) Listing trash contents and disk usage
- Current: uses Finder scripting to list trash items and physical sizes.
- Swift replacement options:
  - Finder scripting (via Apple Events/ScriptingBridge) for consistency.
  - If Finder integration is too heavy, use `FileManager.url(for:in:appropriateFor:create:)` to locate trash and enumerate, but note “put back” metadata is Finder-specific.
- For directory sizes, use `FileManager.enumerator(at:includingPropertiesForKeys:)` and sum `totalFileAllocatedSizeKey` (physical) or `totalFileSizeKey` (logical).

## 6) CLI behavior & UX parity
- Preserve root warning prompt and confirmation flows.
- Keep `-y` bypass for `-e/-s`.
- Preserve verbose logging and list verbose disk usage.
- Keep exit codes consistent with current logic.

## 7) Tests & verification
- Unit tests:
  - Argument parsing matrix and dispatch.
  - Size formatting and file size aggregation.
  - Path handling (relative, absolute, symlink leaf).
- Integration tests (manual or CI):
  - Trash a file and verify it ends in Trash.
  - Finder-based trashing with `-F`.
  - Empty trash behavior and skip‑prompt behavior.

## 8) Documentation & release artifacts
- Update README to reflect SwiftPM build/run.
- Decide whether to keep `trash.pod` and regenerate man page via a Swift-friendly workflow.
- Provide Homebrew formula instructions (or tap update guidance).

## 9) Step-by-step execution plan
1. Scaffold SwiftPM package and add swift-argument-parser.
2. Implement CLI parsing in Swift and stub command handlers.
3. Port output helpers (stdout/stderr + verbose logging).
4. Implement file existence checks and path normalization without following leaf symlinks.
5. Implement standard trashing using `FileManager.trashItem`.
6. Implement Finder-based trashing via Apple Events.
7. Implement list/empty/secure empty flows via Finder bridge.
8. Implement size aggregation + formatting utilities.
9. Wire up fallback logic (permission denied -> Finder).
10. Add tests for parsing, formatting, and file system logic.
11. Update docs/manpage and provide migration notes.
12. Final parity review against Objective‑C behavior.

## 10) Open decisions to confirm
- Minimum macOS target and Swift version.
- Preferred Finder integration approach (Apple Events vs ScriptingBridge).
- Whether to keep the same CLI output strings verbatim.
