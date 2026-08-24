# Releasing

Pushing to `main` is what ships. Claude Code installs this plugin straight from this repo, takes the
tip of `main`, and reads the version from `.claude-plugin/plugin.json`. Your colleagues pick it up
when they next start a session.

Read that twice, because it has a consequence. A tag does not gate a release and neither does the
catalogue in `conclusion-marketplace`. Merge something half finished and it ships. Protect `main` and
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

Finally, create the GitLab release from that tag under **Deploy**, then **Releases**, and paste the
CHANGELOG section in as the notes.

## Checking your work

Our GitLab has no runners attached, so pipelines sit pending and check nothing. Run them yourself:

```bash
bash scripts/check.sh
```

It parses the JSON manifests, confirms the version is SemVer, syntax-checks every shell script and
Python file, resolves all 550 relative Markdown links, and runs `claude plugin validate`. Failures
are all reported together rather than one per run.

Better, let git run it for you:

```bash
git config core.hooksPath scripts/githooks     # once per clone
```

`git push` now runs the checks first and refuses to push if any fail. `git push --no-verify` skips
them when you really mean to.

`.gitlab-ci.yml` calls that same script, so attaching a runner later changes nothing about what gets
checked. Two jobs stay in CI only: `release:check`, which compares both halves of a `*--v*` tag
against `plugin.json` and catches a tag written by hand, and `validate:plugin`, which needs npm on
the runner.

Pipelines are switched off at the top of that file, because GitLab creates one on every push whether
or not a runner can pick it up, and a queue of permanently pending pipelines tells you nothing. To
turn them on the day a runner is attached, add a CI/CD variable `RUN_PIPELINES` with the value `true`
under Settings, then CI/CD, then Variables. Nothing else needs editing.

## Notes

- A colleague on an older version updates at their next session, or immediately from the `/plugin`
  menu.
- To withdraw a bad release, bump to the next PATCH and ship that. Deleting the tag tidies your
  history but takes nothing back, because whoever started a session already has the code. Never
  reuse a version number.
- The catalogue entry in `conclusion-marketplace` carries no version for this plugin, on purpose.
  Nothing over there can check it against this repo, so it would quietly go stale.
