#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

find "./source" -name "*.ipynb" -print0 |
    while IFS= read -r -d '' line; do
        if [[ -z "$(git ls-files "$line")" ]]; then
            # is not tracked by git
            continue
        fi

        (
            cd "$(dirname "$line")"
            pwd
            papermill "$(basename "$line")" "$(basename "/$line")"
            nbstripout --keep-count --keep-output --extra-keys "cell.metadata.papermill metadata.papermill" "$(basename "$line")"
        )
    done
