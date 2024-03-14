# cpp-project-builder-core

cpp-project-builder-core provides a build system based on makefiles containing standard recipes to build C/C++/Assembly multiplatform projects using a GCC-based compiler.

[This repository](https://github.com/ljbo82/cpp-project-builder-core) contains the only the build system. For further details (e.g. documentation, demos, etc.), check project's [official website](tbd).

## Summary

* [License](#license)
* [Usage](#usage)
* [Makefiles](#makefiles)

## License

cpp-project-builder is distributed under MIT License. Please see the [LICENSE](LICENSE) file for details on copying and distribution.

## Basic usage

cpp-project-builder provides a build system intended to be used by C/C++/Assembly projects in order to build source files using a GCC-based compiler.

> **Assumptions**
>
> * Although the build system simplifies a makefile writing process, the developer must have knowledge on how [GNU Make](https://www.gnu.org/software/make/) works, and how to write makfiles. For details, check [GNU Make official documentation](https://www.gnu.org/software/make/manual/make.html).
>
> * Although complex arrangements can be made using the build system, in order make easier the explanation of the concepts, it will be assumed a project containing a single makfile responsible by the compilation/distribution process.
>
> * From this point onwards, the project root directory will be referred to as `<PROJ_ROOT>` and this is the directory where project's `Makefile` is located.


The build system can be either shared by multiple projects or emebedded directly into your project.

The basic usage is comprised by the following steps:

1. Copy or clone the build system into a directory of your preference (from this point onwards, the directory containing the build system will be referred to as `<CPB_DIR>`).

   > **Recommended way to share the build system with multiple projects**
   >
   > It is recommended to declare an environment variable named `CPB_DIR` with value pointing to the directory where the shared build system is located.
   >
   > The variable name can be any valid name, but be sure to refer to the same name in your project's Makefile.

2. Place project's C/C++/Assembly source and header files into specific directories:

   * Source files should be placed into `<PROJ_ROOT>/src`.

   * Global headers should be placed into  `<PROJ_ROOT>/include`.

   > Source and include files can be placed anywhere inside `<PROJ_ROOT>`, but if you use custom directories, you have to declare them in your make file. See [documentation](tbd) for details.

3. Create a `Makefile` inside `<PROJ_ROOT>` containing [variables](tbd) defining how your project shall be built (a minimal Makefile has to provide, at least, the variables `PROJ_NAME` and `PROJ_TYPE`).

4. At the end of your `<PROJ_ROOT>/Makefile`, include the file `builder.mk` provided by the build system:

   ```Makefile
   include $(CPB_DIR)/builder.mk
   ```

Following above guidelines, a minimal Makefile would look like this:

```Makefile
PROJ_NAME = MyProject
PROJ_TYPE = app

include $(CPB_DIR)/builder.mk
```

Now your project is ready to be built.

Just call `make` (from `<PROJ_ROOT>` directory, or use `make -C <PROJ_ROOT>` from any other directory) in order to build your project.

For further details about the build system (e.g. how to customize build process, supporting multiple platforms, etc.), check the [documentation](tbd).

For more examples, check the [demos](https://github.com/ljbo82/cpp-project-builder-demos).

## Makefiles

The build system is composed by multiple makefiles that can be included by your project, depending on its requirements.

Here is a summary of the makefiles provided by the build system:

### builder.mk

This is the main makefile provided by the build system. It contains standard recipes to build C/C++/Assembly multiplatform-ready projects using a GCC-based compiler.

Include this file at the end of your `<PROJ_ROOT>/Makefile`.

See [documentation](tbd) for details.

### doxygen.mk

This file provides standard targets to generate source documentation using [doxygen](https://www.doxygen.nl/index.html).

See [documentation](tbd) for details.

### git.mk

This file inspects `<PROJ_ROOT>` directory and exposes git repository information (current commit, tag, status, etc) through certain variables.

See [documentation](tbd) for details.
