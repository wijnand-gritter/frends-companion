# Releasing

The version users see is `.claude-plugin/plugin.json` → `version`. Claude Code installs this plugin
straight from this repo (the Conclusion marketplace entry points here by git URL), so bumping that
number and pushing to `main` is what delivers a new version on the user's next session. The
catalogue in `conclusion-marketplace` does **not** need a change for a version bump — only for a
description, keyword or source change.

This project follows [SemVer](https://semver.org): `MAJOR.MINOR.PATCH`.
- **PATCH** — doc fixes, corrections, small script fixes.
- **MINOR** — new shapes/triggers/entities, new commands, backwards-compatible features.
- **MAJOR** — breaking changes to plugin structure, command names, or the template contract.

## Cut a release

1. Update `CHANGELOG.md`: move items from `[Unreleased]` into a new `[X.Y.Z]` section with today's
   date, and add the compare/tag links at the bottom.
2. Bump the version in `.claude-plugin/plugin.json` to `X.Y.Z` (optionally bump
   `skills/frends-ipaas-developer/VERSION` too if the skill changed).
3. Commit: `git commit -am "Release vX.Y.Z"`.
4. Tag and push:

   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

The `release:check` job on the tag pipeline fails if the tag does not match `plugin.json`. The
`validate` job runs on every push and merge request: JSON manifests, SemVer, shell and Python
syntax, relative Markdown links, and `claude plugin validate`.

Create the GitLab Release from the tag in **Deploy → Releases** (or `glab release create vX.Y.Z`)
and paste the CHANGELOG section as the notes.

## Notes

- The tag `vX.Y.Z` must equal `plugin.json` `version` `X.Y.Z`, or the tag pipeline fails by design.
- Users update automatically on a new Claude Code session; they can also force it from the `/plugin`
  menu.
- To yank a bad release, delete the tag and Release, bump to the next PATCH, and re-release — don't
  reuse a version number.
