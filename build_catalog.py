#!/usr/bin/env python3
"""Build this app catalog with YunoHost's apps-tools.

This does what apps-tools' list_builder.py does, minus the parts that talk to
YunoHost's own infrastructure:
- no PUT of the app list to the YunoHost forum's tags,
- no error reports to YunoHost's Matrix rooms,
- no lookup of YunoHost's dev CI results, which are keyed by app id and could
  attach YunoHost's "testing" branch info to an app of ours with the same id.

It also fails if any working app is missing from the built catalog, which
list_builder.py only logs.

Usage: build_catalog.py TOOLS_DIR APPS_CACHE TARGET_DIR
"""

import json
import multiprocessing
import sys
from pathlib import Path

tools_dir, cache_path, target_dir = map(Path, sys.argv[1:4])
apps_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(tools_dir.resolve()))

import list_builder  # noqa: E402
from appslib.utils import get_catalog, set_apps_path  # noqa: E402


def main() -> None:
    # The stub below must reach the pool's workers, so don't let them re-import
    multiprocessing.set_start_method("fork")
    list_builder.dev_ci_result_per_branch = lambda: {}

    set_apps_path(apps_dir)
    cache_path.mkdir(exist_ok=True, parents=True)
    catalog = get_catalog(working_only=True)

    print("Retrieving all apps' information to build the catalog...")
    base_catalog = list_builder.build_base_catalog(
        catalog, cache_path, multiprocessing.cpu_count()
    )

    print(f"Writing the catalog to {target_dir}...")
    list_builder.write_catalog_v3(base_catalog, apps_dir, target_dir / "v3")

    built = set(json.loads((target_dir / "v3" / "apps.json").read_text())["apps"])
    missing = set(catalog) - built
    if missing:
        sys.exit(f"Apps missing from the built catalog: {sorted(missing)}")
    print(f"Built {len(built)} apps: {', '.join(sorted(built))}")


if __name__ == "__main__":
    main()
