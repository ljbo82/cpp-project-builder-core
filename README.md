# gcc-project-builder

gcc-project-builder provides a build system based on makefiles containing standard recipes to build C/C++/Assembly multiplatform projects using a GCC-based compiler.

For details, check [official repository](https://github.com/ljbo82/gcc-project-builder).

> **NO OFFICIAL RELEASE YET**
>
> gcc-project-builder is still under development and there is no official releases yet!

## Summary

* [License](#license)
* [Usage](#usage)
* [Makefiles](#makefiles)
  * [builder.mk](#buildermk)
  * [doxygen.mk](#doxygenmk)
  * [functions.mk](#functionsmk)
  * [git.mk](#gitmk)
  * [native-host.mk](#native-hostmk)
  * [project.mk](#projectmk)
* [Examples](#examples)

## License

gcc-project-builder is distributed under MIT License. Please see the [LICENSE](LICENSE) file for details on copying and distribution.

## Usage

gcc-project-builder provides a build system intended to be used by C/C++/Assembly projects in order to build source files using a GCC-based compiler.

> **Assumptions**
>
> * Although the build system simplifies a makefile writing process, the developer must have knowledge on how [GNU Make](https://www.gnu.org/software/make/) works, and how to write makfiles. For details, check [GNU Make official documentation](https://www.gnu.org/software/make/manual/make.html)
>
> * Although complex arrangements can be made using the build system, in order make easier the explanation of the concepts used by gcc-project-builder, it will be assumed a project containing a single makfile responsible by the compilation/distribution process.
>
> * From this point onwards, the project source tree root directory will be referred as `$(PROJ_ROOT)` and this is the directory where project's main Makefile is located.

Typical usage is comprised by the following steps:

1. Clone or copy gcc-project-builder inside directory of your preference (usually inside a subdirectory of `$(PROJ_ROOT)` - this location will be referred from this point onwards as `$(GCC_PROJECT_BUILDER)`).
2. Place project C/C++/Assembly source files into specific directories (usually `$(PROJ_ROOT)/src/` and `$(PROJ_ROOT)/include/`).
3. Create a `$(PROJ_ROOT)/Makefile` containing [variables](https://www.gnu.org/software/make/manual/make.html#Using-Variables) defining how your project shall be built.
4. At the end of your `$(PROJ_ROOT)/Makefile` include the `$(GCC_PROJECT_BUILDER)/builder.mk` provided by the build system:

  ```Makefile
  include $(GCC_PROJECT_BUILDER)/builder.mk
  ```

5. call `make` (from `$(PROJ_ROOT)` directory, or use `make -C $(PROJ_ROOT)` from any other directory) to build your project.

Here is an example of a minimal `$(PROJ_ROOT)/Makefile` used to build an executable with sources contained in `$(PROJ_ROOT)/src/` directory:

```Makefile
PROJ_NAME := hello
PROJ_TYPE := app

include $(GCC_PROJECT_BUILDER)/builder.mk
```

With this minimal makefile, an executable can be build just by calling `make`.

For more examples, check the [demo/](demo) directory.

## Makefiles

The build system is composed by utility makefiles. Here is a summary of the provided ones:

### builder.mk

This is the main makefile. It contains standard recipes to build C/C++/Assembly multiplatform projects using a GCC-based compiler.

Include this file at the end of your `$(PROJ_ROOT)/Makefile`.

See [doc/builder.mk.md](doc/builder.mk.md) for details.

### doxygen.mk

This file provides standard targets to generate source documentation using [doxygen](https://www.doxygen.nl/index.html).

See [doc/doxygen.mk.md](doc/doxygen.mk.md) for details.

### functions.mk

This file provides convenience functions to be used through [`$(call)`](https://www.gnu.org/software/make/manual/make.html#Call-Function).

> NOTE: This file is automatically included by `$(GCC_PROJECT_BUILDER)/builder.mk`

See [doc/functions.mk.md](doc/functions.mk.md) for details.

### git.mk

This file inspects `$(PROJ_ROOT)` directory and exposes git repository information (current commit, tag, status, etc) through read-only variables.

See [doc/git.mk.md](doc/git.mk.md) for details.

### native-host.mk

This file inspects current execution environment and identifies the native host. Identified info is exposed through read-only variables.

> NOTE: This file is automatically included by `$(GCC_PROJECT_BUILDER)/builder.mk`

See [doc/native-host.mk.md](doc/native-host.mk.md) for details.

### project.mk

This file contains the project parser. It is automatically included by [builder.mk](doc/builder.mk.md).

Including this file separately is useful when some logic must be processed after project is fully parsed, but before compilation takes place.

See [doc/project.mk.md](doc/project.mk.md) for details.

## Examples

See [demo/](demo) directory for details.
