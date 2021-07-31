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

PROJ_NAME = app-lib
PROJ_TYPE = app

LIB_PROJ_DIRS += lib/libA

# lib/libB depends on lib/libC (which in turn has its own dependencies but it
# is not required to declare all of them here because gcc-project-builder
# will resolve them internally).
LIB_PROJ_DIRS += lib/libB

include ../../project.mk

ifeq ($(LIB_TYPE), )
    LIB_TYPE := shared
endif

# ==============================================================================
.PHONY: run
run: all
    ifeq ($(LIB_TYPE), shared)
	    $(v)LD_LIBRARY_PATH=$(O)/dist/$(HOST)/lib $(O)/dist/$(HOST)/bin/$(ARTIFACT_NAME)
    else
	    $(v)$(O)/dist/$(HOST)/bin/$(ARTIFACT_NAME)
    endif
# ==============================================================================
