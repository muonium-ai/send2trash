# Agents

This project can be executed by a small set of focused agents. Each agent owns a clear scope and hands off via PRs or patches.

## Roles

1. **Tech Lead / Architect**
   - Defines target macOS and Swift versions.
   - Decides on SwiftPM structure and module boundaries.
   - Approves API compatibility goals for the CLI.

2. **Swift CLI Agent**
   - Ports argument parsing and help text.
   - Implements stdout/stderr utilities and verbose logging.
   - Ensures behavior parity for flags: `-v -l -e -s -y -F` and ignored `rm` flags.

3. **Finder Integration Agent**
   - Implements Finder-based trashing and emptying behavior.
   - Handles “put back” compatibility and Finder frontmost activation.
   - Evaluates Apple Events vs ScriptingBridge approach in Swift.

4. **File System Agent**
   - Implements file existence checks without following leaf symlinks.
   - Implements folder size calculation (logical/physical) and formatting.
   - Handles fallback logic when trashing fails due to permissions.

5. **QA/Release Agent**
   - Defines unit/integration tests and smoke scripts.
   - Updates docs/manpage and verifies Homebrew formula guidance.
   - Validates that behavior matches the Objective‑C version.

## Collaboration Guidelines

- Preserve CLI behavior and messages unless explicitly improved.
- Document any behavioral changes and new dependencies.
- Keep new APIs minimal and aligned with macOS system frameworks.
- Do not modify any files under obj-c/. Treat it as a read-only project archive.
