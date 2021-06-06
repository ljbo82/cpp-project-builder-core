# doxygen.mk

This file provides standard targets to generate source documentation based on [doxygen](https://www.doxygen.nl/index.html).

## Input variables

| Variable        | Mandatory | Defaults   | Details                                                                                 |
|-----------------|-----------|------------|-----------------------------------------------------------------------------------------|
| `O`             | no        | `output`   | Base directory where generated documentation shall be placed into **doc/** subdirectory |
| `DOXYFILE`      | no        | `Doxyfile` | Path of doxygen configuration file                                                      |
| `PRE_DOC`       | no        | _(empty)_  | Commands to be executed on [pre-doc](#pre-doc)                                          |
| `POST_DOC`      | no        | _(empty)_  | Commands to be executed on [post-doc](#post-doc)                                        |

## Make targets

![Targets overview](doxygen_mk_targets.png)

| target                              | Details                               |
|-------------------------------------|---------------------------------------|
| <a name="doc"></a> **doc**          | Generates documentation using doxygen |
| <a name="post-doc"></a>**post-doc** | Executed after internal doc rules     |
| <a name="pre-doc"></a>**pre-doc**   | Executed before internal doc rules    |
