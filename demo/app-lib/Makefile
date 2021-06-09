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

LIBS += lib/libA
LIBS += lib/libB

#NOTE:
# libB depends on libC (which, in turn depends on libD). Transient dependencies
# are handled automatically!

include ../../project.mk

ifeq ($(LIB_TYPE), )
    override LIB_TYPE := shared
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

