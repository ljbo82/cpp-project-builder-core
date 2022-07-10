# project.mk

This is the second most important makefile. It process the project and prepare variables to be processed by the builder.

This file is automatically included by [builder.mk.md](builder.mk.md).

Including this file separately is useful when some logic must be processed after project is fully parsed, but before compilation takes place.
