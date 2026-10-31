#!/usr/bin/env bash
#
# Build this app catalog with YunoHost's apps-tools, and optionally copy the
# result to the place it is served from.
#
# Usage: ./publish_catalog.sh [TARGET_DIR]
#
#   TARGET_DIR    Where to write the catalog (default: builds/default).
#                 YunoHost servers read <catalog url>/v3/apps.json from it.
#
# Environment:
#   PUBLISH_DEST  If set, rsync TARGET_DIR there afterwards,
#                 e.g. "user@host:/var/www/my_webapp/www/catalog".
#   TOOLS_DIR     Where to keep apps-tools and its venv (default: .apps-tools).

set -Eeuo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$REPO_DIR"

# Keep in sync with the ref in .github/workflows/
APPS_TOOLS_REPO="https://github.com/YunoHost/apps-tools"
APPS_TOOLS_REF="dd5882fb6e1da7003f023dced2fe45ac82eb7daf"

: "${TOOLS_DIR:=.apps-tools}"
TARGET_DIR="${1:-builds/default}"
CACHE_DIR=".apps_cache"

if [[ ! -d "$TOOLS_DIR/.git" ]]; then
    git clone --quiet "$APPS_TOOLS_REPO" "$TOOLS_DIR"
fi
if [[ "$(git -C "$TOOLS_DIR" rev-parse HEAD)" != "$APPS_TOOLS_REF" ]]; then
    git -C "$TOOLS_DIR" fetch --quiet origin
    git -C "$TOOLS_DIR" checkout --quiet "$APPS_TOOLS_REF"
fi

if [[ ! -d "$TOOLS_DIR/venv" ]]; then
    python3 -m venv "$TOOLS_DIR/venv"
fi
PYTHON="$TOOLS_DIR/venv/bin/python3"
"$PYTHON" -m pip install --quiet -r "$TOOLS_DIR/requirements-ci.txt"

echo "Checking the catalog files..."
"$PYTHON" "$TOOLS_DIR/catalog_linter.py" --apps-dir .

echo "Fetching the apps' repositories..."
"$PYTHON" "$TOOLS_DIR/app_caches.py" --apps-dir . --apps-cache "$CACHE_DIR" --delete-missing

echo "Building the catalog into $TARGET_DIR..."
"$PYTHON" "$TOOLS_DIR/list_builder.py" --apps-dir . --apps-cache "$CACHE_DIR" "$TARGET_DIR"

# list_builder.py only logs apps it fails to build, so check none went missing
"$PYTHON" - "$TARGET_DIR/v3/apps.json" <<'EOF'
import json, sys, toml
expected = set(toml.load(open("apps.toml")))
built = set(json.load(open(sys.argv[1]))["apps"])
missing = expected - built
if missing:
    sys.exit(f"Apps missing from the built catalog: {sorted(missing)}")
print(f"Built {len(built)} apps: {', '.join(sorted(built))}")
EOF

if [[ -n "${PUBLISH_DEST:-}" ]]; then
    echo "Copying the catalog to $PUBLISH_DEST..."
    rsync -a "$TARGET_DIR/" "$PUBLISH_DEST/"
fi

echo "Done."
