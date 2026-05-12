#!/usr/bin/env python3

import subprocess
import sys

def main():
    """
    Runs the bump_formula_alias.py script for all Gazebo libraries.
    """
    libraries_to_bump = [
        "gz-cmake",
        "gz-common",
        "gz-fuel-tools",
        "gz-gui",
        "gz-math",
        "gz-msgs",
        "gz-physics",
        "gz-plugin",
        "gz-rendering",
        "gz-sensors",
        "gz-sim",
        "gz-tools",
        "gz-transport",
        "gz-utils",
        "sdformat",
    ]

    print("--- Starting to create version aliases for all libraries ---")

    for lib in libraries_to_bump:
        print(f"Processing library: {lib}")
        try:
            result = subprocess.run(
                ["python3", "bump_formula_alias.py", lib],
                capture_output=True,
                text=True,
                check=True  # This will raise an exception for non-zero exit codes
            )
            if result.stdout:
                print(result.stdout.strip())
            if result.stderr:
                print(result.stderr.strip(), file=sys.stderr)

        except subprocess.CalledProcessError as e:
            print(f"Error creating alias for {lib}:", file=sys.stderr)
            print(e.stdout.strip(), file=sys.stderr)
            print(e.stderr.strip(), file=sys.stderr)
        except FileNotFoundError:
            print("Error: 'python3' command not found. Make sure Python 3 is in your PATH.", file=sys.stderr)
            sys.exit(1)
        print("-" * 40)

    print("--- Finished creating all version aliases ---")

if __name__ == '__main__':
    main()
