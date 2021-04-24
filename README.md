# gcc-project-builder

This project provides a standard Makefile containing a build system for C/C++ projects.

# License

gcc-project-builder is distributed under version 2 of the General Public License. Please see the LICENSE file for details on copying and usage.

## Input variables

| Variable                | Mandatory | Default value              | Description                                                                                                                                                                                                                                                                        |
|-------------------------|-----------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **`$(PROJ_NAME)`**      | **YES**   | _n/a_                      | Defines project name. It cannot contain spaces                                                                                                                                                                                                                                     |
| **`$(PROJ_TYPE)`**      | **YES**   | _n/a_                      | Defines project type. Accepted values are **`app`** (for an application) or **`lib`** (for a library)                                                                                                                                                                              |
| **`$(PROJ_VERSION)`**   | no        | `0.1.0`                    | Semantic version (`major.minor.patch`) for the project                                                                                                                                                                                                                             |
| **`$(LIB_TYPE)`**       | no        | `shared`                   | Defines library type. Accepted values are **`shared`** (for a shared library) or **`static`** (for a static library)                                                                                                                                                               |
| **`$(DEBUG)`**          | no        | `0`                        | Defines if a debug version will be built. Although it can be defined in project's Makefile, it is recommended to pass this variable as an environment variable. Accepted values are **`0`** (generates a stripped artifact) and **`1`** (generates an artifact with debug symbols) |
| **`$(V)`**              | no        | `0`                        | Defines if `make` call shall output verbose information for build process. Accepted values are **`0`** (no verbosity) and **`1`** (verbose output)                                                                                                                                 |
| **`$(BUILD_DIR_BASE)`** | no        | `build`                    | Sets the name of the base directory (relative to called Makefile directory) where all build artifacts will be placed                                                                                                                                                               |
| **`$(HOST)`**           | no        | _(empty)_                  | Sets the name which identifies the host for build artifacts (used for cross-compilation)                                    |
| **`$(BUILD_DIR)`**      | no        | `$(HOST)`                  | Sets the name of the directory (relative to `$(BUILD_DIR_BASE)`) where all build artifacts will be placed                   |
| **`$(DIST_DIR_BASE)`**  | no        | `dist`                     | Sets the name of the base directory (relative to called Makefile directory) where all distribution artifacts will be placed |
| **`$(DIST_DIR)`**       | no        | `$(HOST)`                  | Sets the name of the directory (relative to `$(DIST_DIR_BASE)`) where all distribution artifacts will be placed             |
| **`$(SRC_DIRS)`**       | no        | _(empty)_                  | Defines extra source directories to be evaluated during build                                                               |
| **`$(INCLUDE_DIRS)`**   | no        | _(empty)_                  | Defines extra include directories to be evaluated during build                                                              |

## Output variables

| Variable                  | Description                                                                                             |
|---------------------------|---------------------------------------------------------------------------------------------------------|
| **`$(projVersionMajor)`** | Project's major version                                                                                 |
| **`$(projVersionMinor)`** | Project's minor version                                                                                 |
| **`$(projVersionPatch)`** | Project's patch version                                                                                 |
| **`$(fullBuildDir)`**     | Directory (relative to called Makefile directory) where all build artifacts will be placed              |
| **`$(fullDistDir)`**      | Directory (relative to called Makefile directory) where all distribution artifacts will be placed       |
| **`$(srcDirs)`**          | All directories containing source files to be compiled                                                  |
| **`$(includeDirs)`**      | All directories containing header files                                                                 |
| **`$(artifactName)`**     | Name of generated artifact file contained in `$(fullBuildDir)`                                          |

## Targets

_Not applicable_

