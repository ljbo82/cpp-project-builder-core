# gcc-project-builder

gcc-project-builder provides a build system based on Makefiles containing standard recipes to build C/C++ projects.

## Summary

* [License](#license)
* [Usage](#usage)
* [Standard source directories](#standard-source-directories)
* [Standard output directories](#standard-output-directories)
* [Standard hosts](#standard-hosts)
* [Input variables](#input-variables)
  * [Common input variables](#common-input-variables)
  * [Advanced input variables](#advanced-input-variables)
* [Recipes](#recipes)
* [Utility makefiles](#utility-makefiles)

## License

gcc-project-builder is distributed under version 2 of the General Public License. Please see the LICENSE file for details on copying and distribution.

## Usage

gcc-project-builder provides a build system (provided by **project.mk**) intended to be used by C/C++ projects in order to build its source files (C/C++/Assembly) using a GCC-based compiler.

Basically, the usage comprises the following steps:

1. Source files must be located in specific directories
2. Project's Makefile must declare some variables, which are used by the build system to generate an artifact (executable or library)
3. Project's Makefile includes **project.mk**
4. call `make`

Here is an example of a minimal Makefile used to build an executable with sources contained in project's **src/** directory:

```Makefile
PROJ_NAME := hello
PROJ_TYPE := app

include gcc-project-builder/project.mk
```

With this minimal Makefile, an executable can be build just by calling `make`.

For more examples, check the **demo/** directory.

## Standard source directories

When present, these directories (relative to projet Makefile) are used with the following purposes:

* **src/**

  Contains source files and private headers used by application during build. Any kind of file can be placed into this directory, but only files with standard filename extensions are compiled (case-sensitive): **.c** (C source file), **.cpp** (C++ source file), and **.S** (Assembly source file). This directory is also added to compiler's include search path.
  
  Additional source directories can be added to the project through the [`SRC_DIRS`](#var-src-dirs) [input variable](#input-variables).

* **include/**

  Contains public includes (header files) used by application during build. If project is a library, contents of this directory will be copied to [distribution directory](#dir-dist). Any kind of file can be placed into this directory, but no compilation will be performed at all. This directory is added to compiler's include search path.
  
  Additional include directories can be added to the project through the [`INCLUDE_DIRS`](#var-include-dirs) [input variable](#input-variables).

## Standard output directories

gcc-project-builder is inteded to support both native and cross-compilation. During build, output files are placed into host-specific directories (these output directories can be customized through [input variables](#input-variables):

<a name="dir-build"></a>
* **build/&lt;host>/**

  Build directory. Object files as well as final artifact (application executable or library) are placed into this directory. The build directory can be changed through [`BUILD_DIR_BASE`](#var-build-dir-base) and [`BUILD_DIR`](#var-build-dir) [input variables](#input-variables).

<a name="dir-dist"></a>
* **dist/&lt;host>/**

  Distribution directory. Final artifact (and possibly companion header, for libraries) are placed into this directory. Distribution directory can be changed through [`DIST_DIR_BASE`](#var-dist-dir-base) and [`DIST_DIR`](#var-dist-dir) [input variables](#input-variables). Additional directories containing companion headers to be distribuited along with library binary can be added through [`DIST_INCLUDE_DIRS`](#var-dist-include-dirs) [input variable](#input-variables).

## Standard hosts

TBD

## Input variables

The build system provided by **project.mk** can be customized through input variables.

Variable declaration and usage follows Makefile standard syntax.

All input variables must be declared/defined prior to **project.mk** inclusion.

Although it is perfectly legal to declare all input variables in a Makefile (or declaring all of them as environment variables), it its usually better to declare some of them in the Makefile and others as environment variables in order to achieve maximum build flexibility.

### Common input variables

Below are the list the commonly used input variables:

<a name="var-proj-name"></a>
* **`PROJ_NAME`**
  * Mandatory: **YES**
  * Declaration: project's Makefile
  * Default value: _(not applicable)_
  * Description: defines project name. It cannot contain spaces

<a name="var-proj-type"></a>
* **`PROJ_TYPE`**
  * Mandatory: **YES**
  * Declaration: project's Makefile
  * Default value: _(not applicable)_
  * Description: defines project type. Accepted values are `app` (for an application) or `lib` (for a library)

<a name="var-lib-type"></a>
* **`LIB_TYPE`**
  * Mandatory: no
  * Declaration: Either project's Makefile or environment
  * Default value: `shared`
  * Description: defines library type. Accepted values are `shared` (for a shared library) or `static` (for a static library). For [`PROJ_TYPE`](#var-proj-type) other than `lib`, this variable is ignored

<a name="var-proj-version"></a>
* **`PROJ_VERSION`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: `0.1.0`
  * Description: Semantic version (`<major>.<minor>.<patch>`) for the project

<a name="var-debug"></a>
* **`DEBUG`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `0`
  * Description: Defines if a binary with debugging symbols shall be built. Accepted values are `0` (generates a binary WITHOUT debugging info) and `1` (generates an artifact WITH debug symbols)

<a name="var-v"></a>
* **`V`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `0`
  * Description: Defines if `make` call shall output verbose information for build process. Accepted values are `0` (no verbosity) and `1` (verbose output)

<a name="var-host"></a>
* **`HOST`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: _(native host)_
  * Description: Sets the name which identifies the host for build artifacts (used for cross-compiling). The value must follow the syntax `<os>-<arch>`

<a name="var-include-dirs"></a>
* **`INCLUDE_DIRS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Defines extra include directories to be evaluated during build

<a name="var-src-dirs"></a>
* **`SRC_DIRS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Defines extra source directories to be evaluated during build

<a name="var-cross-compile"></a>
* **`CROSS_COMPILE`**
  * Mandatory: no
  * Declaration: Either project's Makefile or environment
  * Default value: _(empty)_
  * Description: Defines GCC prefix used for cross-compiling

<a name="var-cflags"></a>
* **`CFLAGS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Extra flags to be passed to C compiler

<a name="var-cxxflags"></a>
* **`CXXFLAGS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Extra flags to be passed to C++ compiler

<a name="var-asflags"></a>
* **`ASFLAGS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Extra flags to be passed to assembler

<a name="var-ldflags"></a>
* **`LDFLAGS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Extra flags to be passed to the linker. Linker executable will be `$(CROSS_COMPILE)gcc` (if project contains only C source files) or `$(CROSS_COMPILE)g++` (if project containts C++ source files)

<a name="var-prebuild"></a>
* **`PRE_BUILD`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [pre-build](#recipe-pre-build) [recipe](#recipes)

<a name="var-prebuild-deps"></a>
* **`PRE_BUILD_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific depdencies for [pre-build](#recipe-pre-build) [recipe](#recipes)

<a name="var-build-deps"></a>
* **`BUILD_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific dependencies for [build](#recipe-build) [recipe](#recipes)

<a name="var-post-build"></a>
* **`POST_BUILD`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [post-build](#recipe-post-build) [recipe](#recipes)

<a name="var-post-build-deps"></a>
* **`POST_BUILD_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific dependencies for [post-build](#recipe-post-build) [recipe](#recipes)

<a name="var-pre-clean"></a>
* **`PRE_CLEAN`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [pre-clean](#recipe-pre-clean) [recipe](#recipes)

<a name="var-post-clean"></a>
* **`POST_CLEAN`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [post-clean](#recipe-post-clean) [recipe](#recipes)

<a name="var-pre-dist"></a>
* **`PRE_DIST`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [pre-dist](#recipe-pre-dist) [recipe](#recipes)

<a name="var-pre-dist-deps"></a>
* **`PRE_DIST_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific dependencies for [pre-dist](#recipe-pre-dist) [recipe](#recipes)

<a name="var-dist-deps"></a>
* **`DIST_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific dependencies for [dist](#recipe-dist) [recipe](#recipes)

<a name="var-post-dist"></a>
* **`POST_DIST`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Commands to be executed during [post-dist](#recipe-post-dist) [recipe](#recipes)

<a name="var-post-dist-deps"></a>
* **`POST_DIST_DEPS`**
  * Mandatory: no
  * Declaration: Makefile
  * Default value: _(empty)_
  * Description: Project-specific dependencies for [post-dist](#recipe-post-dist) [recipe](#recipes)

### Advanced input variables

Below are the list the input variables for advanced usage:

<a name="var-hosts-dir"></a>
* **`HOSTS_DIR`**
  * TBD

<a name="var-host-mk"></a>
* **`HOST_MK`**
  * TBD

<a name="var-host-mk-required"></a>
* **`HOST_MK_REQUIRED`**
  * TBD

<a name="var-builder-host-mk"></a>
* **`BUILDER_HOST_MK`**
  * TBD

<a name="var-dist-include-dirs"></a>
* **`DIST_INCLUDE_DIRS`**
  * TBD


<a name="var-build-dir-base"></a>
* **`BUILD_DIR_BASE`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `build`
  * Description: Sets the name of the base directory (relative to project Makefile directory) where all build artifacts will be placed

<a name="var-build-dir"></a>
* **`BUILD_DIR`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `$(HOST)`
  * Description: Sets the name of the directory (relative to [`$(BUILD_DIR_BASE)`](#var-build-dir-base) where all build artifacts will be placed

<a name="var-dist-dir-base"></a>
* **`DIST_DIR_BASE`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `dist`
  * Description: Sets the name of the base directory (relative to project Makefile directory) where all distribution artifacts will be placed

<a name="var-dist-dir"></a>
* **`DIST_DIR`**
  * Mandatory: no
  * Declaration: Environment
  * Default value: `$(HOST)`
  * Description: Sets the name of the directory (relative to [`$(DIST_DIR_BASE)`](#var-dist-dir-base)) where all distribution artifacts will be placed

<a name="var-as"></a>
* **`AS`**
  * Mandatory: no
  * Declaration: Environment or Makefile
  * Default value: `as`
  * Description: Sets the name of native assembler executable.

<a name="var-ar"></a>
* **`AR`**
  * Mandatory: no
  * Declaration: Environment or Makefile
  * Default value: `as`
  * Description: Sets the name of native archiver executable.

## Recipes

TBD

## Utility makefiles

TBD

