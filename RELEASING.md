# Releasing

Pushing to `main` is what ships. Claude Code installs this plugin straight from this repo, takes the
tip of `main`, and reads the version from `.claude-plugin/plugin.json`. Your colleagues pick it up
when they next start a session.

Read that twice, because it has a consequence. A tag does not gate a release and neither does the
marketplace entry in `.claude-plugin/marketplace.json`. Merge something half finished and it ships. Protect `main` and
merge only work you would be happy for someone to run tomorrow morning.

So what are the tags for? Answering "what exactly was 0.5.0" six months from now, diffing two
releases, and giving you something to check out when a colleague says last week's version worked.
Bookkeeping worth having, not a safety net.

This project follows [SemVer](https://semver.org): `MAJOR.MINOR.PATCH`.

- **PATCH** for doc fixes, corrections and small script fixes.
- **MINOR** for new shapes, triggers, entities or commands, and any backwards-compatible feature.
- **MAJOR** for a breaking change to the plugin structure, a command name or the template contract.

## Cut a release

1. Move the `[Unreleased]` items in `CHANGELOG.md` into a new `[X.Y.Z]` section with today's date,
   and update the two links at the bottom of the file.
2. Bump `version` in `.claude-plugin/plugin.json`. Bump
   `skills/frends-ipaas-developer/VERSION` as well if the skill itself changed.
3. Commit, then push `main`. Your colleagues now have it.
4. Tag it:

   ```bash
   claude plugin tag --push
   ```

Let that command write the tag rather than typing `git tag` yourself. It reads the name and version
out of `plugin.json`, checks them against any enclosing marketplace entry, refuses a dirty working
tree, and produces the convention Claude Code expects:

```
frends-companion-developer--v0.5.0
```

The plugin name sits in the tag because one repo may hold several plugins, and a bare `v0.5.0` could
not say which. Add `--dry-run` first if you want to see it without creating anything.

The tag push starts `.github/workflows/release.yml`. It checks both halves of the tag against
`plugin.json` and publishes a GitHub release with the matching CHANGELOG section as its notes.

## Checking your work

Run the checks yourself before you push:

```bash
bash scripts/check.sh
```

It parses the JSON manifests, confirms the version is SemVer and the marketplace lists the plugin,
syntax-checks every shell script and Python file, resolves every relative Markdown link, and runs
`claude plugin validate`. Failures are all reported together.

Let git run it for you:

```bash
git config core.hooksPath scripts/githooks     # once per clone
```

`git push` now runs the checks first and refuses to push if any fail. `git push --no-verify` skips
them.

`.github/workflows/ci.yml` runs the same script on every pull request and on `main`. Require that
check in the branch protection rule for `main`, so a pull request cannot merge while it fails.

## Notes

- A colleague on an older version updates at their next session, or immediately from the `/plugin`
  menu.
- To withdraw a bad release, bump to the next PATCH and ship that. Deleting the tag tidies your
  history but takes nothing back, because whoever started a session already has the code. Never
  reuse a version number.
- The marketplace entry carries no version for this plugin, on purpose: `plugin.json` is the one
  place the version lives.
