#!/usr/bin/env python3

"""Unified alias management for the Gazebo Homebrew tap.

Subcommands:
    bump               Create next-major-version aliases for gz-*/sdformat libraries.
    collection-aliases Create collection-scoped aliases (e.g. gz-jetty-cmake).
"""

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
FORMULA_DIR = REPO_ROOT / "Formula"
ALIAS_DIR = REPO_ROOT / "Aliases"

# Matches versioned gz-* and sdformat* formulas, excluding collection formulas
# (gz-jetty.rb has no trailing digits) and ignition-* formulas.
VERSIONED_FORMULA_RE = re.compile(r"^((?:gz-[a-z][-a-z]*|sdformat))(\d+)\.rb$")

# Matches gz-* and sdformat* dependency strings inside a collection formula.
DEPENDS_ON_RE = re.compile(r'depends_on\s+"((?:gz-[a-z][-a-z]*|sdformat)\d+)"')


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def discover_libraries(formula_dir: Path) -> dict[str, int]:
    """Scan Formula/ and return {library_name: latest_version}."""
    libs: dict[str, int] = {}
    for path in sorted(formula_dir.iterdir()):
        m = VERSIONED_FORMULA_RE.match(path.name)
        if m:
            name, version = m.group(1), int(m.group(2))
            if name not in libs or version > libs[name]:
                libs[name] = version
    return libs


def dep_to_short_name(dep: str) -> str:
    """Strip version and gz- prefix to get a short name.

    gz-fuel-tools11 -> fuel-tools
    sdformat16       -> sdformat
    """
    m = re.match(r"^(?:gz-)?(.+?)\d+$", dep)
    return m.group(1) if m else dep


def parse_collection_deps(formula_path: Path) -> list[str]:
    """Extract gz-*/sdformat* dependency names from a collection formula."""
    text = formula_path.read_text()
    return DEPENDS_ON_RE.findall(text)


def create_symlink(alias_path: Path, target: str, *, dry_run: bool) -> None:
    """Create, validate, or fix a symlink at *alias_path* -> *target*."""
    if alias_path.is_symlink():
        current = alias_path.readlink().as_posix()
        if current == target:
            print(f"  {alias_path.name}: already exists, correct")
            return
        # Wrong target — fix it.
        if dry_run:
            print(f"  {alias_path.name}: would fix ({current} -> {target})")
        else:
            alias_path.unlink()
            alias_path.symlink_to(target)
            print(f"  {alias_path.name}: fixed ({current} -> {target})")
        return

    if alias_path.exists():
        print(f"  {alias_path.name}: WARNING — exists but is not a symlink, skipping",
              file=sys.stderr)
        return

    if dry_run:
        print(f"  {alias_path.name}: would create -> {target}")
    else:
        alias_path.symlink_to(target)
        print(f"  {alias_path.name}: created -> {target}")


# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------

def cmd_bump(args: argparse.Namespace) -> int:
    """Create next-major-version aliases for libraries."""
    libs = discover_libraries(FORMULA_DIR)

    if args.libraries:
        # Filter to requested libraries only.
        selected = {}
        for name in args.libraries:
            if name in libs:
                selected[name] = libs[name]
            else:
                print(f"Warning: no versioned formula found for '{name}', skipping",
                      file=sys.stderr)
        libs = selected

    if not libs:
        print("No libraries to process.", file=sys.stderr)
        return 1

    if not args.dry_run:
        ALIAS_DIR.mkdir(exist_ok=True)

    print(f"Processing {len(libs)} libraries (dry_run={args.dry_run}):\n")
    for name in sorted(libs):
        current_ver = libs[name]
        next_ver = current_ver + 1
        alias_name = f"{name}{next_ver}"
        target = f"../Formula/{name}{current_ver}.rb"
        create_symlink(ALIAS_DIR / alias_name, target, dry_run=args.dry_run)

    return 0


def cmd_collection_aliases(args: argparse.Namespace) -> int:
    """Create collection-scoped aliases for a given collection."""
    collection = args.collection
    formula_path = FORMULA_DIR / f"gz-{collection}.rb"

    if not formula_path.exists():
        print(f"Error: formula not found: {formula_path}", file=sys.stderr)
        return 1

    deps = parse_collection_deps(formula_path)
    if not deps:
        print(f"No gz-*/sdformat* dependencies found in {formula_path.name}",
              file=sys.stderr)
        return 1

    if not args.dry_run:
        ALIAS_DIR.mkdir(exist_ok=True)

    print(f"Creating {len(deps)} collection aliases for gz-{collection} "
          f"(dry_run={args.dry_run}):\n")
    for dep in deps:
        short = dep_to_short_name(dep)
        alias_name = f"gz-{collection}-{short}"
        target = f"../Formula/{dep}.rb"
        create_symlink(ALIAS_DIR / alias_name, target, dry_run=args.dry_run)

    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Manage Homebrew aliases for the Gazebo tap.")
    sub = parser.add_subparsers(dest="command", required=True)

    # -- bump --
    bump_p = sub.add_parser(
        "bump",
        help="Create next-major-version aliases (e.g. Aliases/gz-cmake6 -> Formula/gz-cmake5.rb)")
    bump_p.add_argument(
        "libraries", nargs="*", metavar="LIBRARY",
        help="Versionless library names to bump (default: all discovered libraries)")
    bump_p.add_argument(
        "--dry-run", action="store_true",
        help="Print what would be done without creating symlinks")

    # -- collection-aliases --
    col_p = sub.add_parser(
        "collection-aliases",
        help="Create collection-scoped aliases (e.g. Aliases/gz-jetty-cmake -> Formula/gz-cmake5.rb)")
    col_p.add_argument(
        "collection", metavar="COLLECTION",
        help="Collection name without gz- prefix (e.g. jetty, ionic, harmonic)")
    col_p.add_argument(
        "--dry-run", action="store_true",
        help="Print what would be done without creating symlinks")

    args = parser.parse_args()

    if args.command == "bump":
        return cmd_bump(args)
    elif args.command == "collection-aliases":
        return cmd_collection_aliases(args)

    return 0


if __name__ == "__main__":
    sys.exit(main())
