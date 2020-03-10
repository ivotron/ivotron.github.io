#!/bin/sh
#
# taken from: https://gohugo.io/hosting-and-deployment/hosting-on-github/
set -e

if [ "$(git status -s)" ]; then
  echo "The working directory is dirty. Please commit any pending changes."
  exit 1;
fi

GIT_SHA=$(git rev-parse --short HEAD)

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
docker run --rm -it \
  -v ${PWD}:/src \
  -v ${PWD}/public:/target \
  klakegg/hugo:0.67.0-ext

echo "Updating gh-pages branch"
cd public
git add --all
git commit -m "Publishing to gh-pages ${GIT_SHA}"

echo "Pushing to github"
git push --all
