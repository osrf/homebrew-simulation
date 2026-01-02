#!/usr/bin/env python3

import argparse
import glob
import os
import re
import sys

def find_latest_formula(formula_dir, library_name):
    """
    Finds the latest version of a formula in the given directory.
    Returns a tuple of (latest_version_number, latest_formula_path).
    """
    latest_version = -1
    latest_formula_path = None

    # Pattern to match files like `gz-cmake3.rb`, `sdformat12.rb`
    search_path = os.path.join(formula_dir, f'{library_name}*.rb')

    for f_path in glob.glob(search_path):
        filename = os.path.basename(f_path)

        # Regex to extract version from filenames like 'gz-cmake3.rb' or 'sdformat12.rb'
        # It needs to match the library name exactly at the start.
        match = re.match(fr'^{re.escape(library_name)}(\d+)\.rb$', filename)

        if match:
            version = int(match.group(1))
            if version > latest_version:
                latest_version = version
                latest_formula_path = f_path

    if latest_version == -1:
        return None, None

    return latest_version, latest_formula_path

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Create a version-bumped alias for a Homebrew formula by creating a symlink.")
    parser.add_argument('library', help="Versionless name of the library (e.g., 'gz-cmake').")
    args = parser.parse_args()

    formula_dir = 'Formula'
    library_name = args.library

    latest_version, latest_formula_path = find_latest_formula(formula_dir, library_name)

    if not latest_formula_path:
        print(f"Info: Could not find any versioned formulas for '{library_name}'. Skipping.", file=sys.stderr)
        sys.exit(0)

    new_version = latest_version + 1
    latest_formula_basename = os.path.basename(latest_formula_path)

    alias_dir = 'Aliases'
    if not os.path.isdir(alias_dir):
        os.makedirs(alias_dir)
    
    # Construct the alias name based on the library name
    alias_basename = f'{library_name}{new_version}.rb'
    alias_path = os.path.join(alias_dir, alias_basename)

    if os.path.exists(alias_path) or os.path.islink(alias_path):
        real_target = os.readlink(alias_path) if os.path.islink(alias_path) else ''
        expected_target = os.path.join('..', 'Formula', latest_formula_basename)
        if os.path.islink(alias_path) and real_target == expected_target:
             print(f"Alias '{alias_path}' already exists and points to the latest version. Nothing to do.")
        else:
             print(f"Warning: Alias '{alias_path}' already exists but does not point to the latest version. Manual intervention required.", file=sys.stderr)
        sys.exit(0)

    # Create a relative symlink from the Aliases directory to the Formula directory
    symlink_target = os.path.join('..', 'Formula', latest_formula_basename)
    print(f"Creating alias for {library_name} version {new_version}...")
    os.symlink(symlink_target, alias_path)

    print(f"Successfully created alias: {alias_path} -> {symlink_target}")

if __name__ == '__main__':
    main()
