#!/bin/bash
# Lifted from https://github.com/habitat-sh/core-plans

pre-commit install

# The TRAVIS_COMMIT env var is always a merge commit, so we want to test from
# the original commit all the way up until HEAD.
ORIGIN=$(echo "$TRAVIS_COMMIT_RANGE" | cut -f1 -d'.')

pre-commit run --origin HEAD --source "$ORIGIN"
