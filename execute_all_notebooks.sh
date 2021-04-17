#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

exec_notebook () {
    nb_path="$1"
    fname="$(basename "$nb_path")"

    (
        cd "$(dirname "$nb_path")"
        pwd

        jupyfmt -S "$fname"
        papermill "$fname" "$fname"
        nbstripout --keep-count --keep-output --extra-keys "cell.metadata.papermill metadata.papermill" "$fname"
    )
}

find "./source" -name "*.ipynb" -print0 |
    while IFS= read -r -d '' line; do
        if [[ -z "$(git ls-files "$line")" ]]; then
            # is not tracked by git
            continue
        fi

        exec_notebook "$line"
    done
