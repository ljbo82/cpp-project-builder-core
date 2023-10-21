# cpp-project-builder core

cpp-project-builder-core provides a build system based on makefiles containing standard recipes to build C/C++/Assembly multiplatform projects using a GCC-based compiler.

For details, check [official repository](https://github.com/ljbo82/cpp-project-builder-core).

## Summary

* [License](#license)
* [Usage](#usage)
* [Makefiles](#makefiles)

## License

cpp-project-builder is distributed under MIT License. Please see the [LICENSE](LICENSE) file for details on copying and distribution.

## Usage

cpp-project-builder provides a build system intended to be used by C/C++/Assembly projects in order to build source files using a GCC-based compiler.

> **Assumptions**
>
> * Although the build system simplifies a makefile writing process, the developer must have knowledge on how [GNU Make](https://www.gnu.org/software/make/) works, and how to write makfiles. For details, check [GNU Make official documentation](https://www.gnu.org/software/make/manual/make.html)
>
> * Although complex arrangements can be made using the build system, in order make easier the explanation of the concepts used by cpp-project-builder, it will be assumed a project containing a single makfile responsible by the compilation/distribution process.
>
> * From this point onwards, the project source tree root directory will be referred as `$(PROJ_ROOT)` and this is the directory where project's main Makefile is located.

Typical usage is comprised by the following steps:

1. Clone or copy cpp-project-builder-core inside directory of your preference (usually inside a subdirectory of `$(PROJ_ROOT)` - this location will be referred from this point onwards as `$(CPP_PROJECT_BUILDER)`).
2. Place project C/C++/Assembly source files into specific directories (usually `$(PROJ_ROOT)/src/` and `$(PROJ_ROOT)/include/`).
3. Create a `$(PROJ_ROOT)/Makefile` containing [variables](https://www.gnu.org/software/make/manual/make.html#Using-Variables) defining how your project shall be built.
4. At the end of your `$(PROJ_ROOT)/Makefile` include the `$(CPP_PROJECT_BUILDER)/project.mk` provided by the build system:

  ```Makefile
  include $(CPP_PROJECT_BUILDER)/project.mk
  ```

5. call `make` (from `$(PROJ_ROOT)` directory, or use `make -C $(PROJ_ROOT)` from any other directory) to build your project.

Here is an example of a minimal `$(PROJ_ROOT)/Makefile` used to build an executable with sources contained in `$(PROJ_ROOT)/src/` directory:

```Makefile
PROJ_NAME := hello
PROJ_TYPE := app

include $(CPP_PROJECT_BUILDER)/project.mk
```

With this minimal makefile, an executable can be build just by calling `make`.

For more examples, check the [demo](https://github.com/ljbo82/cpp-project-builder-demos) repository.

## Makefiles

The build system is composed by utility makefiles. Here is a summary of the provided ones:

### doxygen.mk

This file provides standard targets to generate source documentation using [doxygen](https://www.doxygen.nl/index.html).

See [documentation](https://github.com/ljbo82/cpp-project-builder-doc/blob/master/doxygen.mk.md) for details.

### git.mk

This file inspects `$(PROJ_ROOT)` directory and exposes git repository information (current commit, tag, status, etc) through read-only variables.

See [documentation](https://github.com/ljbo82/cpp-project-builder-doc/blob/master/git.mk.md) for details.

### project.mk

This is the main makefile. It contains standard recipes to build C/C++/Assembly multiplatform projects using a GCC-based compiler.

Include this file at the end of your `$(PROJ_ROOT)/Makefile`.

See [documentation](https://github.com/ljbo82/cpp-project-builder-doc/blob/master/project.mk.md) for details.
