# Scripts

## manage_aliases.py

Unified tool for managing Homebrew aliases in the Gazebo tap.

### Subcommands

#### `bump` — Next-major-version aliases

Creates aliases that point the *next* major version to the *current* latest
formula. For example, `Aliases/gz-cmake6 -> ../Formula/gz-cmake5.rb`.

```bash
# Bump all discovered gz-*/sdformat libraries
python3 scripts/manage_aliases.py bump

# Preview without creating anything
python3 scripts/manage_aliases.py bump --dry-run

# Bump specific libraries only
python3 scripts/manage_aliases.py bump gz-cmake sdformat
```

Libraries are auto-discovered from `Formula/` — no hardcoded list.

#### `collection-aliases` — Collection-scoped aliases

Creates aliases that give a collection-prefixed name to each dependency of a
collection formula. For example,
`Aliases/gz-jetty-cmake -> ../Formula/gz-cmake5.rb`.

```bash
# Create aliases for the Jetty collection
python3 scripts/manage_aliases.py collection-aliases jetty

# Preview first
python3 scripts/manage_aliases.py collection-aliases jetty --dry-run
```

Dependencies are parsed from `Formula/gz-{collection}.rb`.

### Behavior

- **Auto-discovery**: `bump` scans `Formula/` so new libraries are picked up
  automatically.
- **Idempotent**: re-running reports "already exists, correct" for valid
  aliases.
- **Auto-fix**: wrong symlink targets are corrected automatically (the old
  script required manual intervention).
- **`--dry-run`**: preview all changes without touching the filesystem.
- Alias files have no `.rb` extension (Homebrew convention).
- Symlink targets are relative (`../Formula/…`).
