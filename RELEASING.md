# Releasing

The version users see is `fc-integration/.claude-plugin/plugin.json` → `version`. Claude Code pulls
updates from this marketplace repo, so bumping that number and pushing to `main` is what delivers a
new version to users on their next session. Tags and GitHub Releases make each version visible and
auditable.

This project follows [SemVer](https://semver.org): `MAJOR.MINOR.PATCH`.
- **PATCH** — doc fixes, corrections, small script fixes.
- **MINOR** — new shapes/triggers/entities, new commands, backwards-compatible features.
- **MAJOR** — breaking changes to plugin structure, command names, or the template contract.

## Cut a release

1. Update `CHANGELOG.md`: move items from `[Unreleased]` into a new `[X.Y.Z]` section with today's date.
2. Bump the version in `fc-integration/.claude-plugin/plugin.json` to `X.Y.Z`
   (optionally bump `skills/frends-ipaas-developer/VERSION` too if the skill changed).
3. Commit: `git commit -am "Release vX.Y.Z"`.
4. Tag and push:

   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

The **Release** workflow verifies the tag matches `plugin.json`, then publishes a GitHub Release with
auto-generated notes. The **CI** workflow validates JSON manifests, SemVer, shell/Python syntax, and
Markdown links on every push and PR.

## Notes

- The tag `vX.Y.Z` must equal `plugin.json` `version` `X.Y.Z`, or the release job fails by design.
- Users update automatically on a new Claude Code session; they can also force it from the `/plugin`
  menu.
- To yank a bad release, delete the tag and GitHub Release, bump to the next PATCH, and re-release —
  don't reuse a version number.
