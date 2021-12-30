# gcc-project-builder/doc

This directory contains the documentation for each makefile provided by the build system:

> **Assumptions**
>
> * Although the build system simplifies a makefile writing process, the developer must have knowledge on how [GNU Make](https://www.gnu.org/software/make/) works, and how to write makfiles. For details, check [GNU Make official documentation](https://www.gnu.org/software/make/manual/make.html)
>
> * Although complex arrangements can be made using the build system, in order make easier the explanation of the concepts used by gcc-project-builder, it will be assumed a project containing a single makfile responsible by the compilation/distribution process.
>
> * From this point onwards, the project source tree root directory will be referred as `$(PROJ_ROOT)` and this is the directory where project's main Makefile is located.

### builder.mk

This is the main makefile. Include it at the end of your `$(PROJ_ROOT)/Makefile`.

See [builder.mk.md](builder.mk.md) for details.

### doxygen.mk

This file provides standard targets to generate source documentation using [doxygen](https://www.doxygen.nl/index.html).

See [doxygen.mk.md](doxygen.mk.md) for details.

### functions.mk

This file provides convenience functions to be used through [`$(call)`](https://www.gnu.org/software/make/manual/make.html#Call-Function).

> NOTE: This file is automatically included by `$(GCC_PROJECT_BUILDER)/builder.mk`

See [functions.mk.md](functions.mk.md) for details.

### git.mk

This file inspects `$(PROJ_ROOT)` directory and exposes git repository information (current commit, tag, status, etc) through read-only variables.

See [git.mk.md](git.mk.md) for details.

### native-host.mk

This file inspects current execution environment and identifies the native host. Identified info is exposed through read-only variables.

> NOTE: This file is automatically included by `$(GCC_PROJECT_BUILDER)/builder.mk`

See [native-host.mk.md](native-host.mk.md) for details.
