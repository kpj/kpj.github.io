#!/bin/bash
set -euo pipefail

# git checkout --orphan gh-pages
# git reset --hard
# git commit --allow-empty -m "Init"
# git checkout master

rm -rf _build
git worktree add _build gh-pages
make html
cd _build

cp -a html/. .
rm -r html

git add .
git commit -m "Update gh-pages (ref-commit: $(git log '--format=format:%H' master -1))"
git push origin gh-pages

cd ..
git worktree remove _build
