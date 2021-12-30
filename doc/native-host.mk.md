# native-host.mk

This file inspects current execution environment and identifies the native host. Identified info is exposed through read-only variables.

## Variables

Following are described all variables used/exported by this makefile:

> **Variable details**
>
> For each detailed variable, the following fields refer to:
>
> * **Description:** contains descriptive information about the variable.
> * **Mandatory:** defines if a variable must be defined during build.
> * **Default value:** contains the value which will be assumed if variable is optional and it is not defined.
> * **Allowed origins:** defines where variable is allowed to be defined (command line, environment, makefile, etc).
> * **Restrictions:** Contain information about restrictions on which kind of values that can be stored in the variable.

<a name="NATIVE_OS"></a>
* **`NATIVE_OS`**

  * **Description:** Native operating system. Possible/supported values are `linux`, `osx`, and `windows`. If native operating system is not supported by this makefile, variable will be undefined.
  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.

<a name="NATIVE_ARCH"></a>
* **`NATIVE_ARCH`**

  * **Description:** Native processor architecture. Possible/supported values are `x86`, `x64`, `arm`, and `arm64`. If native processor architecture is not supported by this makefile, variable will be undefined.
  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.

<a name="NATIVE_HOST"></a>
* **`NATIVE_HOST`**

  * **Description:** Contains the concatenation `$(NATIVE_OS)-$(NATIVE_ARCH)`.

    * If only [`$(NATIVE_OS)`](#NATIVE_OS) was detected, value will be [`$(NATIVE_OS)`](#NATIVE_OS).
    * If  [`$(NATIVE_OS)`](#NATIVE_OS) was not detected, variable will be undefined.

  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.
