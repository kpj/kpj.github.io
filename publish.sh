#!/bin/bash
set -euo pipefail

# Note: user pages must be published from master branch
# git checkout --orphan master
# git reset --hard
# git commit --allow-empty -m "Initial commit"
# git checkout source

rm -rf _build
git worktree add _build master
make html
cd _build

cp -a html/. .
rm -r html

git add .
git commit -m "Update master (ref-commit: $(git log '--format=format:%H' source -1))"
git push origin master

cd ..
git worktree remove _build
