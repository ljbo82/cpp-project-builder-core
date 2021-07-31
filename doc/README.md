# gcc-project-builder

gcc-project-builder provides a build system based on Makefiles containing standard targets to build C/C++ projects.

For details, check [official repository](https://github.com/ljbo82/gcc-project-builder).

## Summary

* [License](#license)
* [Cloning](#cloning)
* [Usage](#usage)
* [Default source directories](#default-source-directories)
* [Output directories](#output-directories)
* [Hosts](#hosts)
* [Input variables](#input-variables)
  * [Common input variables](#common-input-variables)
  * [Advanced input variables](#advanced-input-variables)
* [Make targets](#make-targets)
* [Utility makefiles](#utility-makefiles)
  * [doxygen.mk](#doxygenmk)
  * [functions.mk](#functionsmk)
  * [git.mk](#gitmk)
  * [native_host.mk](#native_hostmk)

## License

gcc-project-builder is distributed under version 2 of the General Public License. Please see the [LICENSE](../LICENSE) file for details on copying and distribution.

## Cloning

This repository uses [git-lfs](https://git-lfs.github.com/) to version some binaries files (for instance: images in [doc/](.) directory). Ensure extension is installed before cloning this repository.

## Usage

gcc-project-builder provides a build system (through **project.mk**) intended to be used by C/C++ projects in order to build its source files (C/C++/Assembly) using a GCC-based compiler.

Basically, the usage comprises the following steps:

1. Clone gcc-project-builder as a [git submodule](https://git-scm.com/docs/gitsubmodules) inside your project or copy distribution package into a subdirectory inside project tree.
2. Place source files into specific directories (usually **src/** and **include/**).
3. Declare [variables](#input-variables) for gcc-project-builder customization (at least [`PROJ_NAME`](#PROJ_NAME) and [`PROJ_TYPE`](#PROJ_TYPE)) inside your project's Makefile.
4. Include **project.mk** (provided by gcc-project-builder).
5. call `make` to build your project.

Here is an example of a minimal Makefile used to build an executable with sources contained in project's **src/** directory:

```Makefile
PROJ_NAME := hello
PROJ_TYPE := app

include gcc-project-builder/project.mk
```

With this minimal Makefile, an executable can be build just by calling `make`.

For more examples, check the [demo/](../demo) directory.

## Default source directories

When present, these directories (relative to project's Makefile) are used (by default) with the following purposes:

* **src/**

  Contains source files and private headers used by application during build. Any kind of file can be placed into this directory, but only source files with standard filename extensions are compiled (case-sensitive): **.c** (C source file), **.cpp** (C++ source file), and **.S** (Assembly source file). This directory is also added to compiler's include search path.

  Additional source directories can be added to the project through [`SRC_DIRS`](#SRC_DIRS) [input variable](#input-variables).

* **include/**

  Contains public includes (header files) used by application during build. If project is a library, header files (**\*.h** or **\*.hpp**) inside this directory will be copied to [distribution directory](#dir-dist). Any kind of file can be placed into this directory, but no compilation will be performed at all. This directory is added to compiler's include search path.

  Additional include directories can be added to the project through [`INCLUDE_DIRS`](#INCLUDE_DIRS) and [`DIST_INCLUDE_DIRS`](#DIST_INCLUDE_DIRS) [input variables](#input-variables).

> **Skip default source & include directories**
>
> Default source & include directories handling can be ignored by build system through setting the value of [`SKIP_DEFAULT_SRC_DIR`](#SKIP_DEFAULT_SRC_DIR) and [`SKIP_DEFAULT_INCLUDE_DIR`](#SKIP_DEFAULT_INCLUDE_DIR) [advanced variables](#advanced-input-variables).

## Output directories

All generated files are placed (by default) into **output/** base directory. This directory can be changed through [`O`](#O) enviroment variable.

> **Version control**
>
> Output base directory shall be ignored by your source code version control system.

Inside output base directory (**`$(O)/`**) you may find some directories according to project type (note that listed directories depends on [`HOST`](#HOST) [variable](#input-variables)):

* **`$(O)/build/$(HOST)/$(BUILD_DIR)`**

  Build directory. Object files as well as final artifact (application executable or library) are placed into this directory.

  NOTE: By default, [`BUILD_DIR`](#BUILD_DIR) is empty.

* **`$(O)/dist/$(HOST)/$(DIST_DIR)`**

  Distribution directory. Final artifact (executable or library), and possibly companion header (for libraries) are placed into this directory.

  NOTE: By default, [`DIST_DIR`](#DIST_DIR) is empty.

  * **`$(O)/dist/$(HOST)/$(DIST_DIR)/bin/`**

    If project builds an application executable, resulting binary is placed into this directory.

  * **`$(O)/dist/$(HOST)/$(DIST_DIR)/lib/`**

    If project builds a library (either static o shared), resulting binary is placed into this directory.

  * **`$(O)/dist/$(HOST)/$(DIST_DIR)/include/`**

    If project builds a library (either static of shared), companion headers are placed into this directory.

    Additional directories containing companion headers to be distribuited along with library binary can be added through [`DIST_INCLUDE_DIRS`](#DIST_INCLUDE_DIRS) [variable](#input-variables).

    Companion headers must have either **.h** or **.hpp** filename extensions.

## Hosts

_To be documented_

## Input variables

The build system provided by **project.mk** can be customized through input variables.

Variable declaration and usage follows [Makefile standard syntax](https://www.gnu.org/software/make/manual/html_node/Using-Variables.html#Using-Variables).

By convention, input variables are named in `UPPER_CASE` fashion.

All input variables must be declared/defined prior to **project.mk** inclusion.

Although it is perfectly legal to declare all input variables in a Makefile (or declaring all of them as environment variables), it is usually better to declare some of them in the Makefile and others as environment variables in order to achieve maximum build flexibility.

### Common input variables

Below are the list the commonly used input variables:

<a name="PROJ_NAME"></a>
* **`PROJ_NAME`**
  * Mandatory: **YES**
  * Common declaration: project's Makefile
  * Default value: _(not applicable)_

  Defines project name. It cannot contain spaces.

<a name="PROJ_TYPE"></a>
* **`PROJ_TYPE`**
  * Mandatory: **YES**
  * Common declaration: project's Makefile
  * Default value: _(not applicable)_

  Defines project type. Accepted values are `app` (for an application) or `lib` (for a library).

<a name="LIB_TYPE"></a>
* **`LIB_TYPE`**
  * Mandatory: no
  * Common declaration: Either project's Makefile or environment
  * Default value: `shared`

  Defines library type. Accepted values are `shared` (for a shared library) or `static` (for a static library).

  For [`PROJ_TYPE`](#PROJ_TYPE) other than `lib`, this variable is ignored.

<a name="PROJ_VERSION"></a>
* **`PROJ_VERSION`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `0.1.0`

  Semantic version (`<major>.<minor>.<patch>`) for the project.

<a name="DEBUG"></a>
* **`DEBUG`**
  * Mandatory: no
  * Common declaration: Environment
  * Default value: `0`

  Defines if a binary with debugging symbols shall be built. Accepted values are `0` (generates a release binary WITHOUT debugging info) and `1` (generates an artifact WITH debug symbols).

<a name="V"></a>
* **`V`**
  * Mandatory: no
  * Common declaration: Environment
  * Default value: `0`

  Defines if `make` call shall output verbose information for build process. Accepted values are `0` (no verbosity) and `1` (verbose output).

<a name="HOST"></a>
* **`HOST`**
  * Mandatory: no
  * Common declaration: Environment
  * Default value: _(native host)_

  Sets the name which identifies the host for build artifacts (used for cross-compiling).

  The value must follow the syntax `<os>-<arch>`. For more details, see [hosts](#hosts) section.

<a name="INCLUDE_DIRS"></a>
* **`INCLUDE_DIRS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_ (if **include/** directory DOES NOT exist) or `include` (if **include/** directory exists).

  Defines include directories to be added to compiler search path during build.

<a name="SRC_DIRS"></a>
* **`SRC_DIRS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_ (if **src/** directory DOES NOT exist) or `src` (if **src/** directory exists).

  Defines extra source directories containing files to be compiled. Paths must be inside project tree (project's root is where `Makefile` is located).

<a name="CROSS_COMPILE"></a>
* **`CROSS_COMPILE`**
  * Mandatory: no
  * Common declaration: Either project's Makefile or environment
  * Default value: _(empty)_

  Defines GCC prefix used for cross-compiling.

<a name="CFLAGS"></a>
* **`CFLAGS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Extra flags to be passed to C compiler.

<a name="CXXFLAGS"></a>
* **`CXXFLAGS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Extra flags to be passed to C++ compiler.

<a name="ASFLAGS"></a>
* **`ASFLAGS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Extra flags to be passed to the assembler.

<a name="LDFLAGS"></a>
* **`LDFLAGS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Extra flags to be passed to the linker.

  NOTE: Linker executable will be either `$(CROSS_COMPILE)gcc` (if project contains only C source files) or `$(CROSS_COMPILE)g++` (if project containts C++ source files).

<a name="PRE_CLEAN"></a>
* **`PRE_CLEAN`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [pre-clean](#pre-clean) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="POST_CLEAN"></a>
* **`POST_CLEAN`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [post-clean](#post-clean) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="PRE_BUILD"></a>
* **`PRE_BUILD`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [pre-build](#pre-build) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="PREBUILD_DEPS"></a>
* **`PRE_BUILD_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [pre-build](#pre-build) [target](#targets).

<a name="BUILD_DEPS"></a>
* **`BUILD_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [build](#build) [target](#targets).

<a name="POST_BUILD"></a>
* **`POST_BUILD`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [post-build](#post-build) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="POST_BUILD_DEPS"></a>
* **`POST_BUILD_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [post-build](#post-build) [target](#targets).

<a name="PRE_DIST"></a>
* **`PRE_DIST`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [pre-dist](#pre-dist) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="PRE_DIST_DEPS"></a>
* **`PRE_DIST_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [pre-dist](#pre-dist) [target](#targets).

<a name="DIST_DEPS"></a>
* **`DIST_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [dist](#dist) [target](#targets).

<a name="POST_DIST"></a>
* **`POST_DIST`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Commands to be executed during [post-dist](#post-dist) [target](#targets).

  NOTE: Commands must be delimited by shell command delimiter (usually `&&` or `;`).

<a name="POST_DIST_DEPS"></a>
* **`POST_DIST_DEPS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Project-specific dependencies for [post-dist](#post-dist) [target](#targets).

<a name="O"></a>
* **`O`**
  * Mandatory: no
  * Common declaration: Environment
  * Default value: `output`

  Sets the name of the base [output directory](#output-directories) (relative to project Makefile directory), where all generated artifacts will be placed into.

<a name="LIBS"></a>
* **`LIBS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Lists the libs (libname) used during link. Although libraries can be passed through [LDFLAGS](#LDFLAGS), LIBS variable usage is preferred because it is used to resolve transitive dependencies when using [`LIB_PROJ_DIRS`](#LIB_PROJ_DIRS).

<a name="LIB_PROJ_DIRS"></a>
* **`LIB_PROJ_DIRS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  Lists dependencies on library projects (which uses gcc-project-builder for building).

  Each entry has the following syntax (items inside brackets are optional):

  ```
  project_dir[:makefile[:target[:env_var1=env_var1[:env_var2=env_var2]...]]]]
  ```

  * `project_dir`: Project directory containing a **Makefile** using gcc-project-builder.
  * `makefile`: [Optional] Name of the makefile to be used (defaults to **Makefile**).
  * `target`: [Optional] Name of the target to be called (defaults value is empty).
  * `envX_var`: [Optional] Optional environment variables passed to `make` project.

### Advanced input variables

Below are the list the input variables for advanced usage:

<a name="BUILD_DIR"></a>
* **`BUILD_DIR`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value:  _(empty)_

  Sets name for a directory (inside `$(O)/build/$(HOST)`) where build artifacts shall be placed.

<a name="DIST_DIR"></a>
* **`DIST_DIR`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value:  _(empty)_

  Sets name for a directory (inside `$(O)/dist/$(HOST)`) where distribution artifacts shall be placed.

<a name="VARS"></a>
* **`VARS`**
  * Mandatory: no (except for [printvars](#printvars) target)
  * Common declaration: Environment
  * Default value: _(empty)_

  This variable defines the list of variables names which shall be inspected through [printvars](#printvars) target.

<a name="ARTIFACT_BASE_NAME"></a>
* **`ARTIFACT_BASE_NAME`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value:
    * Debug artifacts: `$(PROJ_NAME)$(projVersionMajor)_d`
    * Release artifacts: `$(PROJ_NAME)$(projVersionMajor)`

  Defines the base name for generated artifact. The value is used as a base for final [`ARTIFACT_NAME`](#ARTIFACT_NAME). By default, debug artifacts (`DEBUG == 1`) have a `_d` suffix.

<a name="ARTIFACT_NAME"></a>
* **`ARTIFACT_NAME`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _Varies according to [`ARTIFACT_BASE_NAME`](#ARTIFACT_BASE_NAME), [`PROJ_TYPE`](#PROJ_TYPE), [`LIB_TYPE`](#LIB_TYPE) and [`HOST`](#HOST)_.

  Defines the actual filename for target artifact. Note that default value depends on many variables. It is not recommended to change the artifact name unless you have a really good reason to do so.

<a name="HOSTS_DIR"></a>
* **`HOSTS_DIR`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `hosts`

  Defines the directory (relative to project's Makefile) which contains host-specific makefile to be included (if present).

  The default value is usually enough for most projects.

  This variable is useful for projects supporting specific hosts.

<a name="HOST_MK"></a>
* **`HOST_MK`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(depends on selected [`HOST`](#HOST))_

  This variable defines the name of the file inside [`HOSTS_DIR`](#HOSTS_DIR) which must be included for selected [`HOST`](#HOST).

  For details regarding default behavior, see [hosts](#hosts) section.

<a name="HOST_MK_REQUIRED"></a>
* **`HOST_MK_REQUIRED`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `0`

  This variable defines if `$(HOSTS_DIR)/$(HOST_MK)` must exist in order to build proceed.

  This variable is useful for projects targeting only specific hosts. When enabled (if its value is `1`), a valid hosts makefile must exist, otherwise an error will be raised informing that selected host is not supported.

<a name="BUILDER_HOST_MK"></a>
* **`BUILDER_HOST_MK`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(depends on selected [`HOST`](#HOST))_

  This variable defines the name (including the path relative to project's Makefile) of host-specific makefile included by builder which contains instructions how to build artifacts.

  For almost 100% of use-cases, default value is enough. For details regarding default behavior, see [hosts](#hosts) section.

  NOTE: Changing this variable is rarely required. Changing this variable is really an advanced topic and it is usually performed when creating a custom build system on top of gcc-project-builder (e.g.: [arduino-gcc-project-builder](https://github.com/ljbo82/arduino-gcc-project-builder)).

<a name="DIST_INCLUDE_DIRS"></a>
* **`DIST_INCLUDE_DIRS`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  This variable defines additional directories containing companion header files which must be copied to distribution package. Specified directories are also added to compiler include search path.

<a name="DIST_FILES"></a>
* **`DIST_FILES`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: _(empty)_

  List of tokens in format `distFile:srcFile` where `distFile` is a path inside `$(O)/dist/$(HOST)/$(DIST_DIR)` and `srcFile` is a path inside project's tree which will be copied into `distFile`. This variable is useful to add custom files into distribution directory.

<a name="SKIP_DEFAULT_SRC_DIR"></a>
* **`SKIP_DEFAULT_SRC_DIR`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `0`

  This variable defines if [default source directory](#default-source-directories) handling shall be ignored by build system. Once ignored, this directory although still can be used as a source directory, but rather their usage must be declared explicitly (through [`SRC_DIRS`](#SRC_DIRS) variable).

<a name="SKIP_DEFAULT_INCLUDE_DIR"></a>
* **`SKIP_DEFAULT_INCLUDE_DIR`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `0`

  This variable defines if [default include directory](#default-source-directories) handling shall be ignored by build system. Once ignored, this directory although still can be used as an include directory, but rather their usage must be declared explicitly (through either [`INCLUDE_DIRS`](#INCLUDE_DIRS), or [`DIST_INCLUDE_DIRS`](#DIST_INCLUDE_DIRS) variables).

<a name="STRIP_RELEASE"></a>
* **`STRIP_RELEASE`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `1`

  Defines if release artifacts (when [`DEBUG`](#DEBUG) is `0`) shall be stripped. Accepted values are `0` and `1`.

<a name="OPTIMIZE_RELEASE"></a>
* **`OPTIMIZE_RELEASE`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `1`

  Defines if release artifacts (when [`DEBUG`](#DEBUG) is `0`) shall be optimized (using compiler optimizations. Optimization level is defined in [`OPTIMIZATION_LEVEL`](#OPTIMIZATION_LEVEL) variable). Accepted values are `0` and `1`.

<a name="OPTIMIZATION_LEVEL"></a>
* **`OPTIMIZATION_LEVEL`**
  * Mandatory: no
  * Common declaration: Makefile
  * Default value: `2`

  If optimization is enabled for release artifacts (see [`OPTIMIZE_RELEASE`](#OPTIMIZE_RELEASE)), defines the optimization level used by gcc during build.

  NOTE: There is no check for given value.

<a name="AS"></a>
* **`AS`**
  * Mandatory: no
  * Common declaration: Environment or Makefile
  * Default value: `as`

  Sets the name of native assembler executable.

<a name="AR"></a>
* **`AR`**
  * Mandatory: no
  * Common declaration: Environment or Makefile
  * Default value: `ar`

  Sets the name of native archiver executable.

## Make targets

**project.mk** provides standard targets used for almost all kind of C/C++ projects:

![Targets overview](project_mk_targets.png)

<a name="all"></a>
* **all**

  Default target. Just depends on [dist](#dist) target.

<a name="clean"></a>
* **clean**

  Removes all compiled artifacts. It is preceeded by [pre-clean](#pre-clean) and followed by [post-clean](#post-clean). Internal cleaning rules basically, removes the [base output directory](#output-directories).

<a name="pre-clean"></a>
* **pre-clean**

  Executes all comands declared in [`PRE_CLEAN`](#PRE_CLEAN) variable.

<a name="post-clean"></a>
* **post-clean**

  Executes all comands declared in [`POST_CLEAN`](#POST_CLEAN) variable.

<a name="build"></a>
* **build**

  Compiles all source files and generate target binary (executable or library). Internal build rules are preceeded by [pre-build](#pre-build) target and is is followed by [post-build](#post-build) target.

<a name="pre-build"></a>
* **pre-build**

  Executes all comands declared in [`PRE_BUILD`](#PRE_BUILD) variable. This target is preceeded by dependencies declared in [`PRE_BUILD_DEPS`](#PRE_BUILD_DEPS) variable.

<a name="post-build"></a>
* **post-build**

  Executes all comands declared in [`POST_BUILD`](#POST_BUILD) variable. This target is preceeded by dependencies declared in [`POST_BUILD_DEPS`](#POST_BUILD_DEPS) variable.


<a name="dist"></a>
* **dist**

  Generate distribuition tree. It depends on [build](#build) target. Internal distribution rules are preceeded by [pre-dist](#pre-dist) target and is followed by [post-dist](#post-dist) target.

<a name="pre-dist"></a>
* **pre-dist**

  Executes all comands declared in [`PRE_DIST`](#PRE_DIST) variable. This target is preceeded by dependencies declared in [`PRE_DIST_DEPS`](#PRE_DIST_DEPS) variable.

<a name="post-dist"></a>
* **post-dist**

  Executes all comands declared in [`POST_DIST`](#POST_DIST) variable. This target is preceeded by dependencies declared in [`POST_DIST_DEPS`](#POST_DIST_DEPS) variable.

<a name="printvars"></a>
* **printvars**

  This target is used internally when solving dependencies. For general usage, this target is used mostly for debugging purposes.

  List the values for variables selected through `VARS` environment variable.

  For example, to get the value of both [`srcFiles`](#srcFiles) and [`objFiles`](#objFiles):

  ```bash
  $ make printvars VARS='srcFiles objFiles'
  ```

  Generates the following output (for [app demo](../demo/app)):

  ```
  src/main.c output/build/linux-x64/src/main.c.o
  ```

## Output variables

Once included, **project.mk** also exposes some variables that can be used inside project's Makefile (usually through [recusively expanded variables](https://www.gnu.org/software/make/manual/html_node/Flavors.html#Flavors), since **project.mk** is normally included at the end of project's Makefile):

By convention, output variables are named in `camelCase` fashion.

Note: Not all output variables are documented because some of them are targeted only for internal use.

| Variable         | Details                                                       |
|------------------|---------------------------------------------------------------|
| projVersionMajor | Major version extracted from [`PROJ_VERSION`](#PROJ_VERSION)  |
| projVersionMinor | Mintor version extracted from [`PROJ_VERSION`](#PROJ_VERSION) |
| projVersionPatch | Patch version extracted from [`PROJ_VERSION`](#PROJ_VERSION)  |
| hostOS           | OS component extracted from [`HOST`](#HOST)                   |
| hostArch         | Arch component extract from [`HOST`](#HOST)                   |
| buildDir         | Directory where all built artifacts are placed                |
| distDir          | Directory where distribution artifacts are placed             |

## Utility makefiles

Along with **project.mk**, gcc-project-builder provides some utility makefiles which can be included into your project's Makefile in order to add more targets, exposing functions, and exporting output variables, and so on.

### doxygen.mk

This file provides standard targets to generate source documentation based on [doxygen](https://www.doxygen.nl/index.html).

See [doxygen.mk.md](doxygen.mk.md) for details.

### functions.mk

This file provides convenience Makefile functions.

NOTE: This file is included by **project.mk**.

See [functions.mk.md](functions.mk.md) for details.

### git.mk

This file inspects project's directory tree and exposes git repository information (current commit, tag, status, etc) through output variables.

See [git.mk.md](git.mk.md) for details.

### native_host.mk

This file inspects current execution environment and identifies (some) native host. Identified info is exposed through output variables.

NOTE: This file is included by **project.mk** when [`HOST`](#HOST) variable is not set.

See [native_host.mk.md](native_host.mk.md) for details.
