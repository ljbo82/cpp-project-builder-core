# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

PROJ_NAME = app_lib
PROJ_TYPE = app

ifeq ($(LIB_TYPE), )
    LIB_TYPE := static
endif

mylib_libName      = $(shell $(MAKE) -s -C ../lib printvars LIB_TYPE=$(LIB_TYPE) VARS='ARTIFACT_BASE_NAME')
mylib_artifactName = $(shell $(MAKE) -s -C ../lib printvars LIB_TYPE=$(LIB_TYPE) VARS='ARTIFACT_NAME')

BUILD_DEPS   += $(O)/libs/mylib/dist/$(HOST)/$(mylib_artifactName)
LDFLAGS      += -L$(O)/libs/mylib/dist/$(HOST)/lib -l$(mylib_libName)
INCLUDE_DIRS += $(O)/libs/mylib/dist/$(HOST)/include

include ../../project.mk

# BUILD_DEPS ===================================================================
$(O)/libs/mylib/dist/$(HOST)/$(mylib_artifactName):
	@printf "$(nl)[BUILD] $@\n"
	@rm -f $(buildDir)/$(ARTIFACT_NAME) $(distDir)/bin/$(ARTIFACT_NAME)
	$(v)$(MAKE) -C ../lib LIB_TYPE=$(LIB_TYPE) O=$(abspath $(O))/libs/mylib
# ==============================================================================

