# git.mk

This file inspects project's directory tree and exposes git repository information (current commit, tag, status, etc) through output variables.

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

<a name="GIT_REPO_DIR"></a>
* **`GIT_REPO_DIR`**

  * **Description:** Defines directory to be inspected.
  * **Mandatory:** no
  * **Default value:** `.` _(current directory)_
  * **Allowed origins:** _(any)_
  * **Restrictions:** Value shall not contain whitespaces nor can be an empty string.

<a name="GIT_STATUS"></a>
* **`GIT_STATUS`**

  * **Description:** Contains repository status. Possible values are:

    * `clean` : Repository does not contain uncommited changes
    * `dirty` : Repository contains uncommited changes.

    If [`$(GIT_REPO_DIR)`](#GIT_REPO_DIR) is not versioned by git, variable will be undefined.

  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.

<a name="GIT_COMMIT"></a>
* **`GIT_COMMIT`**

  * **Description:** Contains current commit for the repository. If directory is not versioned by git, variable will be undefined
  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.

<a name="GIT_COMMIT_SHORT"></a>
* **`GIT_COMMIT_SHORT`**

  * **Description:** Contains current short commit for the repository. If directory is not versioned by git, variable will be undefined
  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.

<a name="GIT_TAG"></a>
* **`GIT_TAG`**

  * **Description:** Contains current tag for the repository. If directory is not versioned by git, variable will be undefined
  * **Mandatory:** _(N/A)_
  * **Default value:** _(N/A)_
  * **Allowed origins:** _(N/A)_
  * **Restrictions:** This is a read-only variable. Its value is set by this makefile and cannot be modified.
