# git.mk

This file inspects project's directory tree and exposes git repository information (current commit, tag, status, etc) through output variables.

## Input variables

Below are listed all accepted input variable (i.e. variables that must be declared before this makefile include):


| Variable   | Mandatory | Defaults | Details                                       |
|------------|-----------|----------|-----------------------------------------------|
| `REPO_DIR` | no        | `.`      | Directory containing git repo to be inspected |

## Output variables

| Variable    | Details                                                                                                       |
|-------------|---------------------------------------------------------------------------------------------------------------|
| `gitCommit` | Repository current commit (if `$(REPO_DIR)` does not contain a valid git repository, returns an empty value)  |
| `gitStatus` | Repo status: `0` (clean), `1` (dirty), empty (`$(REPO_DIR)` does not contain a valid git repo)                |
| `gitTag`    | Current tag or empty (if either there is no available tag or `$(REPO_DIR)` does not contain a valid git repo) |
