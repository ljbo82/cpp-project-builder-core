# native_host.mk

This file tries to identify native host and exposes detected info through output variables.

## Output variables

| Variable    | Details                                                                                                 |
|-------------|---------------------------------------------------------------------------------------------------------|
| `nativeOS`  | Native operating system. Supported values are `linux` and `windows`                                     |
| `nativeArch | Processor architecture. Supported values are `x64` and `x86`                                            |
