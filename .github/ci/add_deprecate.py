#!/usr/bin/env python3
import argparse
import glob
import os
import re
import sys

def main():
    parser = argparse.ArgumentParser(
        description="Add a deprecate! statement above the depends_on block in specified Formula file(s)."
    )
    parser.add_argument(
        "date",
        help="Deprecation date in YYYY-MM-DD format (e.g. 2026-12-15)"
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="Formula file(s) or pattern(s) to update (e.g. Formula/gz-math7.rb or Formula/gz-*.rb)"
    )
    parser.add_argument(
        "--because",
        default=":deprecated_upstream",
        help="Reason for deprecation (default: :deprecated_upstream)"
    )

    args = parser.parse_args()

    # Validate YYYY-MM-DD format
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", args.date):
        print(f"Error: Invalid date format '{args.date}'. Expected YYYY-MM-DD format.", file=sys.stderr)
        sys.exit(1)

    # Expand any glob patterns passed in files
    target_files = []
    for arg in args.files:
        expanded = glob.glob(arg)
        if expanded:
            target_files.extend(sorted(expanded))
        elif os.path.exists(arg):
            target_files.append(arg)
        else:
            print(f"Warning: File or pattern not found: {arg}", file=sys.stderr)

    if not target_files:
        print("No valid formula files specified.", file=sys.stderr)
        sys.exit(1)

    updated_files = []

    for filepath in target_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        if "deprecate!" in content:
            print(f"Skipping {filepath} (deprecate! already present)")
            continue

        # Locate the first depends_on statement in the formula
        pattern = re.compile(r'^(?P<indent>[ \t]*)depends_on\b', re.MULTILINE)
        match = pattern.search(content)

        if not match:
            print(f"Skipping {filepath} (no depends_on block found)")
            continue

        indent = match.group("indent")
        deprecate_line = f'{indent}deprecate! date: "{args.date}", because: {args.because}'

        # Insert deprecate! above the first depends_on statement with a blank line in between
        start = match.start()
        new_content = content[:start] + deprecate_line + "\n\n" + content[start:]

        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)

        updated_files.append(filepath)
        print(f"Updated {filepath} with deprecate! date: \"{args.date}\", because: {args.because}")

    print(f"\nSuccessfully updated {len(updated_files)} file(s).")

if __name__ == "__main__":
    main()
