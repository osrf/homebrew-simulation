# CI Scripts

This directory contains maintenance and helper scripts used in continuous integration, release management, and formula updates for the `osrf/simulation` Homebrew tap.

---

## Table of Contents

- [add\_deprecate.py](#add_deprecatepy)
- [bottled\_dependents.sh](#bottled_dependentssh)
- [create\_rotary\_formulae.sh](#create_rotary_formulaesh)
- [disable\_deprecated\_formulae\_in\_days.py](#disable_deprecated_formulae_in_dayspy)
- [print-homebrew-simulation-badges.bash](#print-homebrew-simulation-badgesbash)
- [unbottled\_dependencies.sh](#unbottled_dependenciessh)

---

### `add_deprecate.py`

Adds a `deprecate!` statement above the first `depends_on` block in the specified formula file(s). Skips files that already contain `deprecate!`.

#### Usage

```bash
./.github/ci/add_deprecate.py <YYYY-MM-DD> <files...> [--because <reason>]
```

#### Options

- `date`: Deprecation date formatted as `YYYY-MM-DD` (e.g., `2026-12-15`).
- `files`: One or more formula file paths or glob patterns (e.g., `Formula/gz-math7.rb` or `Formula/gz-*.rb`).
- `--because`: Deprecation reason (default: `:deprecated_upstream`).

#### Examples

Deprecate a single formula:
```bash
./.github/ci/add_deprecate.py 2026-12-15 Formula/gz-math7.rb
```

Deprecate multiple formulae with a custom reason:
```bash
./.github/ci/add_deprecate.py 2026-12-15 Formula/gz-sim8.rb Formula/gz-gui8.rb --because ':version_eol'
```

Deprecate formulae that directly depend on `gz-cmake4` (used for the Ionic end-of-life deprecation):
```bash
./.github/ci/add_deprecate.py 2026-12-15 $(grep -rlI 'depends_on "gz-cmake4"')
```

---

### `bottled_dependents.sh`

Finds and prints bottled dependents of a given formula from the `osrf/simulation` tap that are not currently installed.
This is designed for CI environments without pre-installed formulae to determine which reverse dependencies have bottles.
The script is used by the [generic-release-homebrew\_remove\_dependent\_bottles](https://build.osrfoundation.org/job/generic-release-homebrew_remove_dependent_bottles/)
CI job, which is useful for recursively removing broken bottles.

#### Usage

```bash
./.github/ci/bottled_dependents.sh <formula> [<bottle_tag>]
```

#### Arguments

- `<formula>`: Name of the formula to inspect.
- `[<bottle_tag>]` *(optional)*: Bottle platform/architecture tag (e.g., `arm64_tahoe`). If omitted, checks against the current host system.

#### Examples

Check bottled dependents for the host architecture:
```bash
./.github/ci/bottled_dependents.sh gz-jetty-msgs
```

Check bottled dependents for a specific macOS architecture/version:
```bash
./.github/ci/bottled_dependents.sh gz-jetty-msgs arm64_sequoia
```

---

### `create_rotary_formulae.sh`

Generates development/HEAD (`rotary`) formula variants from existing Gazebo `jetty` formula aliases.

Specifically, it:
1. Iterates over `Aliases/gz-jetty-*`.
2. Creates unversioned development formulae in `Formula/gz-rotary-*.rb` targeting the `main` branch.
3. Rewrites class names and dependencies to reference `gz-rotary-*`.
4. Removes existing bottle blocks, checksums, and release URLs.
5. Adds appropriate `conflicts_with` statements between jetty and rotary formulae.
6. Creates symlinks in `Aliases/` for the next version number pointing to the rotary formula.
7. Runs `brew style --fix` on generated rotary formulae.

#### Usage

```bash
# Run from repository root
./.github/ci/create_rotary_formulae.sh
```

---

### `disable_deprecated_formulae_in_days.py`

Scans all formulae in `Formula/*.rb` for `deprecate!` statements whose deprecation date has already passed.
For each matching formula that does not already have a `disable!` statement,
it inserts a `disable!` statement scheduled for a specified number of days in the future,
preserving the original deprecation reason.

#### Usage

```bash
./.github/ci/disable_deprecated_formulae_in_days.py [<days>]
```

#### Arguments

- `[<days>]` *(optional)*: Number of days from today when the formula should be disabled (default: `30`).

#### Examples

Disable formulae whose deprecation date has passed in 30 days:
```bash
./.github/ci/disable_deprecated_formulae_in_days.py
```

Set the disable date to 60 days from today:
```bash
./.github/ci/disable_deprecated_formulae_in_days.py 60
```

---

### `print-homebrew-simulation-badges.bash`

Fetches generated CI job definitions from `gazebo-tooling/release-tools` and
generates a Markdown badge table showing the build/install status for Gazebo
collections across supported architectures (e.g. `arm64`).

The output can be redirected or copied directly into the tap's main `README.md`.

#### Usage

```bash
./.github/ci/print-homebrew-simulation-badges.bash [<release_tools_branch>]
```

#### Examples

Print to stdout the Markdown table and link reference definitions for current Jenkins jobs:
```bash
./.github/ci/print-homebrew-simulation-badges.bash
```

Print to stdout the Markdown table and link reference definitions for Jenkins jobs configured on `my_branch` of release-tools:
```bash
./.github/ci/print-homebrew-simulation-badges.bash my_branch
```

Update or inspect generated badge output:
```bash
./.github/ci/print-homebrew-simulation-badges.bash > /tmp/badges.md
```

---

### `unbottled_dependencies.sh`

Inspects dependencies of a specified formula from the `osrf/simulation` tap and
prints any that do not currently have bottles available.
The script is used by the [generic-release-homebrew\_bump\_unbottled\_dependencies](https://build.osrfoundation.org/job/generic-release-homebrew_bump_unbottled_dependencies/)
CI job, which is used to open a pull request with incremented formula revisions
so that the missing bottles can be built.

#### Usage

```bash
./.github/ci/unbottled_dependencies.sh <formula> [<bottle_tag>]
```

#### Arguments

- `<formula>`: Formula name to check.
- `[<bottle_tag>]` *(optional)*: Bottle platform/architecture tag (e.g., `arm64_tahoe`). If omitted, checks the current host system.

#### Examples

Check unbottled dependencies for the host architecture:
```bash
./.github/ci/unbottled_dependencies.sh gz-jetty
```

Check unbottled dependencies for a specific platform tag:
```bash
./.github/ci/unbottled_dependencies.sh gz-jetty arm64_tahoe
```
