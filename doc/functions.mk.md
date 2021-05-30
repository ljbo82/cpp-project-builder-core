# functions.mk

This file provides utility functions that can be used by other makefiles (using [`$(call)`](https://www.gnu.org/software/make/manual/html_node/Call-Function.html)).

## Exposed functions

| Function                            | Details                                                                      |
|-------------------------------------|------------------------------------------------------------------------------|
| `$(call fn_version_valid, version)` | Returns `1` if `version` is a valid semantic version. Otherwise, returns `0` |
| `$(call fn_version_major, version)` | Returns the major component for given `version`                              |
| `$(call fn_version_minor, version)` | Returns the minor component for given `version`                              |
| `$(call fn_version_patch, version)` | Returns the patch component for given `version`                              |
| `$(call fn_host_valid, host)`       | Returns `1` if `host` is a valid host string                                 |
| `$(call fn_host_os, host)`          | Returns the OS component for given `host`                                    |
| `$(call fn_host_arch, host)`        | Returns the ARCH component for given `host`                                  |
