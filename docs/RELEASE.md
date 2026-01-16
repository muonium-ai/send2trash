# Release Checklist

## Preflight
- [ ] Ensure working tree is clean. (pending: local changes exist)
- [x] Update version in Sources/TrashCore/TrashCore.swift.
- [x] Update README TODO and any release notes.
- [x] Run unit tests: `make test`.
- [x] Run smoke tests (manual): `make smoke-test`.

## Build & package
- [x] Build release binary: `make build` (or `swift build -c release`).
- [x] Generate man page: `make docs` (requires `pod2man`).
- [x] Verify `send2trash -v` and `send2trash -l` output.

## Install & verify
- [ ] Install: `make install` (check PATH if needed).
- [ ] Verify `which send2trash` points to the installed binary.
- [ ] Trash a sample file and confirm it appears in Trash.

## Publish
- [ ] Tag release in git and push.
- [ ] Update Homebrew formula or tap if applicable.
