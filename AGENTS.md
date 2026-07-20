# Agent notes for uYouEnhanced

## What this repo is

uYouEnhanced is a Theos iOS tweak that enhances the YouTube app (fork lineage from uYou / uYouPlus). Primary sources live in `Sources/`; bundled tweaks live under `Tweaks/` as submodules.

## Repository rules (Cursor)

Project rules for Cloud Agents and IDE agents live in:

- `.cursor/rules/*.mdc`

Always follow those rules. In particular:

1. Use the name **uYouEnhanced** only (never `uYouPlusExtra`).
2. Do **not** publish or distribute `.ipa` files.
3. Keep changes scoped; prefer `Sources/` and project build files over drive-by submodule rewrites.

## Useful paths

| Path | Purpose |
|------|---------|
| `Sources/` | Main tweak code (Logos / ObjC) |
| `Makefile` | Theos build, versions, inject dylibs |
| `Localizations/uYouPlus.bundle/` | Strings and app icons |
| `CODE_OF_CONDUCT.md` | Project policy (naming, IPA ban) |
| `.github/workflows/` | CI (build / submodule updates) |

## When unsure

Read neighboring files in `Sources/` and mirror their style. Check `SettingsKeys.h` before inventing new preference keys.
