# doxygen.mk

This file provides standard targets to generate source documentation based on [doxygen](https://www.doxygen.nl/index.html).

## Input variables

| Variable                                    | Mandatory | Defaults   | Details                                                                                 |
|---------------------------------------------|-----------|------------|-----------------------------------------------------------------------------------------|
| <a name="O"></a>`O`                         | no        | `output`   | Base directory where generated documentation shall be placed into **doc/** subdirectory |
| <a name="DOXYFILE"></a>`DOXYFILE`           | no        | `Doxyfile` | Path of doxygen configuration file                                                      |
| <a name="DOXYARGS"></a>`DOXYARGS`           | no        | _(empty)_  | Doxyfile variables to be passed to doxygen command (syntax: `VAR_NAME=VAR_VALUE`)       |
| <a name="DOC_DEPS"></a>`DOC_DEPS`           | no        | _(empty)_  | Project-specific depdencies for internal doc rules                                      |
| <a name="PRE_DOC"></a>`PRE_DOC`             | no        | _(empty)_  | Commands to be executed on [pre-doc](#pre-doc)                                          |
| <a name="PRE_DOC_DEPS"></a>`PRE_DOC_DEPS`   | no        | _(empty)_  | Project-specific depdencies for [pre-doc](#pre-doc) target                              |
| <a name="POST_DOC"></a>`POST_DOC`           | no        | _(empty)_  | Commands to be executed on [post-doc](#post-doc)                                        |
| <a name="POST_DOC_DEPS"></a>`POST_DOC_DEPS` | no        | _(empty)_  | Project-specific depdencies for [post-doc](#post-doc) target                            |

## Output variables

| Variable                                  | Description                                                                     |
|-------------------------------------------|---------------------------------------------------------------------------------|
| <a name="docOutputDir"></a>`docOutputDir` | The directory where doxygen generated documentation will be placed (`$(O)/doc`) |

## Make targets

![Targets overview](doxygen_mk_targets.png)

| target                              | Details                                                                                  |
|-------------------------------------|------------------------------------------------------------------------------------------|
| <a name="doc"></a> **doc**          | Generates documentation using doxygen                                                    |
| <a name="pre-doc"></a>**pre-doc**   | Executed before internal doc rules. Runs commands declared in [`PRE_DOC`](#var-PRE_DOC)  |
| <a name="post-doc"></a>**post-doc** | Executed after internal doc rules. Runs commands declared in [`POST_DOC`](#var-POST_DOC) |
