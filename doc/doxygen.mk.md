# doxygen.mk

This file provides standard targets to generate source documentation based on [doxygen](https://www.doxygen.nl/index.html).

## Input variables

| Variable        | Mandatory | Defaults   | Details                                                 |
|-----------------|-----------|------------|---------------------------------------------------------|
| `DOC_BUILD_DIR` | no        | `dist/doc` | Directory where generated documentation shall be placed |
| `DOXYFILE`      | no        | `Doxyfile` | Path of doxygen configuration file                      |
| `PRE_DOC`       | no        | _(empty)_  | Commands to be executed on [pre-doc](#target-pre-doc)   |
## Make targets

![Targets overview](doxygen_mk_targets.png)

| target                              | Details                               |
|-------------------------------------|---------------------------------------|
| <a name="doc"></a> **doc**          | Generates documentation using doxygen |
| <a name="post-doc"></a>**post-doc** | Executed after internal doc rules     |
 
