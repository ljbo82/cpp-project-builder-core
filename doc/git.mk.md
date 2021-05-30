# git.mk

This file inspects project's directory tree and exposes git repository information (current commit, tag, status, etc) through output variables.

## Input variables

Below are listed all accepted input variable (i.e. variables that must be declared before this makefile include):


| Variable   | Mandatory | Defaults | Details                                       |
|------------|-----------|----------|-----------------------------------------------|
| `REPO_DIR` | no        | `.`      | Directory containing git repo to be inspected |

## Output variables

| Variable    | Details                                                                                                  |
|-------------|----------------------------------------------------------------------------------------------------------|
| `gitCommit` | Repository current commit (if directory does not contain a valid git repository, returns an empty value) |
| `gitStatus` | Repo status: `0` (clean), `1` (dirty)                                                                    |
| `gitTag`    | Current tag                                                                                              |
