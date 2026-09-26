#!/usr/bin/env python3
import argparse
import datetime
import glob
import re
import sys

def main():
    parser = argparse.ArgumentParser(
        description="Add disable! statement after deprecate! in Formula files if deprecate! date has passed."
    )
    parser.add_argument(
        "days",
        type=int,
        nargs="?",
        default=30,
        help="Number of days from today for the disable! date (default: 30)"
    )
    args = parser.parse_args()

    today = datetime.date.today()
    target_date = (today + datetime.timedelta(days=args.days)).strftime("%Y-%m-%d")
    print(f"Current date: {today}")
    print(f"Target disable date ({args.days} days from today): {target_date}")

    formula_files = sorted(glob.glob("Formula/*.rb"))
    updated_files = []

    for filepath in formula_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        if "deprecate!" not in content or "disable!" in content:
            continue

        # =========================================================================
        # REGEX PATTERN DOCUMENTATION
        # =========================================================================
        # Pattern:
        #   r'^(?P<indent>[ \t]*)(?P<deprecate>deprecate!\s+date:\s*"(?P<date>\d{4}-\d{2}-\d{2})",\s*(?P<because>because:\s*.*))\n(?:\s*\n)?'
        #
        # Component Breakdown:
        #   ^                             : Anchor - matches start of line (re.MULTILINE)
        #   (?P<indent>[ \t]*)            : Group 'indent' - captures leading spaces/tabs
        #   (?P<deprecate>                : Group 'deprecate' - captures full deprecate! call:
        #     deprecate!\s+date:\s*"      : Matches 'deprecate!', spaces, 'date:' & opening quote '"'
        #     (?P<date>\d{4}-\d{2}-\d{2}) : Group 'date' - captures ISO date YYYY-MM-DD
        #     ",\s*                       : Matches closing quote '"', comma ',', and spaces
        #     (?P<because>because:\s*.*)  : Group 'because' - captures 'because:' and everything to end of line
        #   )                             : End group 'deprecate'
        #   \n                            : End of the deprecate! line
        #   (?:\s*\n)?                    : Non-capturing group - matches optional blank line following deprecate!
        # =========================================================================
        pattern = re.compile(
            r'^(?P<indent>[ \t]*)(?P<deprecate>deprecate!\s+date:\s*"(?P<date>\d{4}-\d{2}-\d{2})",\s*(?P<because>because:\s*.*))\n(?:\s*\n)?',
            re.MULTILINE
        )

        def replacer(match):
            indent = match.group("indent")
            deprecate_text = match.group("deprecate")
            deprecate_date_str = match.group("date")
            because = match.group("because")

            deprecate_date = datetime.datetime.strptime(deprecate_date_str, "%Y-%m-%d").date()

            # Skip if deprecation date is in the future
            if deprecate_date > today:
                print(f"Skipping {filepath} (deprecate! date {deprecate_date_str} has not passed yet)")
                return match.group(0)

            disable_line = f'{indent}disable! date: "{target_date}", {because}'
            return f'{indent}{deprecate_text}\n{disable_line}\n\n'

        new_content, count = pattern.subn(replacer, content)
        if count > 0 and new_content != content:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            updated_files.append(filepath)
            print(f"Updated {filepath}")

    print(f"\nSuccessfully updated {len(updated_files)} file(s).")

if __name__ == "__main__":
    main()
